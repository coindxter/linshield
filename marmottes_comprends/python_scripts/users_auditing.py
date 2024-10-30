import os
import json
import subprocess
import random


if os.getuid() != 0:
    print('You are not root')
    exit(1)

if __name__ != '__main__':
    print('This isn\'t the main program')
    exit(0)

with open('.marmottes-configs/ReadMe.json', 'r') as file:
    data = json.load(file)

admins = [user for user in data['all_users'] if user['account_type'] == 'admin']
new_users = data["new_users"]
users = [user for user in data['all_users'] if user['account_type'] != 'admin']

currentAdmin = os.popen('logname').read().strip()

min_uuid = 1000
max_uuid = 60000

output = subprocess.check_output(f"awk -F':' -v min=\"{min_uuid}\" -v max=\"{max_uuid}\"" + " '{ if ($3 >= min && $3 <= max) print $1}' /etc/passwd", shell=True)
currentUsers = output.decode().strip().split('\n')
output = subprocess.check_output(f"getent group sudo adm | cut -d: -f4 | tr ',' '\n' | sort -u", shell=True)
currentAdmins = output.decode().strip().split('\n')

unAuthorizedUsers = [user for user in currentUsers if user not in [user['name'] for user in users] and user not in [user['name'] for user in admins] and user not in [user['name'] for user in new_users]]
missingUsers = [user for user in users if user['name'] not in currentUsers]
unAuthorizedAdmins = [user for user in currentAdmins if user not in [user['name'] for user in admins]]
missingAdmins = [user for user in admins if user['name'] not in currentAdmins]

if unAuthorizedUsers:
    print('Unauthorized users:')
    for user in unAuthorizedUsers:
        print(f'  - {user}')

if missingUsers:
    print('Missing users:')
    for user in missingUsers:
        print(f'  - {user["name"]}')

if unAuthorizedAdmins:
    print('Unauthorized admins:')
    for user in unAuthorizedAdmins:
        print(f'  - {user}')

if missingAdmins:
    print('Missing admins:')
    for user in missingAdmins:
        print(f'  - {user["name"]}')

fix = input('Would you like to fix these issues? (yes/no): ')
if fix == 'yes' or fix == 'y':
    for user in missingUsers:
        user["password"] = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=16))
        subprocess.run(f'useradd -m -s /bin/bash -U {user["name"]}', shell=True)
        subprocess.run(f'echo "{user["name"]}:{user["password"]}" | chpasswd', shell=True)
        subprocess.run(f'chage -d 0 {user["name"]}', shell=True)

    for user in missingAdmins:
        if user['name'] == currentAdmin:
            continue
        # check if user exists
        user["password"] = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=16))
        if user['name'] not in currentUsers:
            subprocess.run(f'useradd -m -s /bin/bash -U {user["name"]}', shell=True)
            subprocess.run(f'echo "{user["name"]}:{user["password"]}" | chpasswd', shell=True)
            subprocess.run(f'chage -d 0 {user["name"]}', shell=True)
        subprocess.run(f'usermod -aG sudo {user["name"]}', shell=True)
        subprocess.run(f'usermod -aG adm {user["name"]}', shell=True)

    for user in unAuthorizedUsers:
        subprocess.run(f'userdel -r {user}', shell=True)

    for user in unAuthorizedAdmins:
        if user == currentAdmin:
            continue
        subprocess.run(f'deluser {user} sudo', shell=True)
        subprocess.run(f'deluser {user} adm', shell=True)

    for user in new_users:
        subprocess.run(f'useradd -m -s /bin/bash -U {user["name"]}', shell=True)
        subprocess.run(f'echo "{user["name"]}:{user["password"]}" | chpasswd', shell=True)
        subprocess.run(f'chage -d 0 {user["name"]}', shell=True)
        if user['account_type'] == 'admin':
            subprocess.run(f'usermod -aG sudo {user["name"]}', shell=True)
            subprocess.run(f'usermod -aG adm {user["name"]}', shell=True)

    for user in users:
        user["password"] = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=16))
        subprocess.run(f'echo "{user["name"]}:{user["password"]}" | chpasswd', shell=True)

    for user in admins:
        if user['name'] == currentAdmin:
            continue
        user["password"] = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=16))
        subprocess.run(f'echo "{user["name"]}:{user["password"]}" | chpasswd', shell=True)

    print('Summary:')

    if unAuthorizedUsers:
        print('Removed these users:')
        for user in unAuthorizedUsers:
            print(f'  - {user}')

    if missingUsers:
        print('Added these users:')
        for user in missingUsers:
            print(f'  - {user["name"]}')
            print(f'  - {user["password"]}')

    if unAuthorizedAdmins:
        print('Removed these admins:')
        for user in unAuthorizedAdmins:
            print(f'  - {user}')

    if missingAdmins:
        print('Added these admins:')
        for user in missingAdmins:
            print(f'  - {user["name"]}')
            print(f'  - {user["password"]}')

    if new_users:
        print('Added these new users:')
        for user in new_users:
            print(f'  - {user["name"]}')
            print(f'  - {user["password"]}')

    for user in users:
        print(f'Updated password for {user["name"]}')
        print(f'  - {user["password"]}')

    for user in admins:
        print(f'Updated password for {user["name"]}')
        if user['name'] == currentAdmin:
            print('  - Original password')
            continue
        print(f'  - {user["password"]}')