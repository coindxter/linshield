import subprocess
import json

groups = dict(zip([x.split(":")[0] for x in subprocess.run('awk -F\':\' \'$4 {print}\' /etc/group | grep -v "sudo" | grep -v "adm" | grep -v "audio" | grep -v "cdrom"', shell=True, stdout=subprocess.PIPE).stdout.decode('utf-8').strip().split('\n')], [x.split(":")[-1].split(",") for x in subprocess.run('awk -F\':\' \'$4 {print}\' /etc/group | grep -v "sudo" | grep -v "adm" | grep -v "audio" | grep -v "cdrom"', shell=True, stdout=subprocess.PIPE).stdout.decode('utf-8').strip().split('\n')]))

with open('.marmottes-configs/ReadMe.json') as f:
    readme = json.load(f)
    users = readme['all_users']
    for user in readme['new_users']:
        users.append(user)

groups_to_create = []
missing_from_group = []
should_not_be_in_group = []

for user in users:
    for group in user['groups']:
        if group not in groups:
            groups_to_create.append(group)
            missing_from_group.append({
                "user": user['name'],
                "group": group
            })    
        else:
            if user['name'] not in groups[group]:
                missing_from_group.append({
                    "user": user['name'],
                    "group": group
                })    
            else:
                should_not_be_in_group.append({
                    "user": user['name'],
                    "group": group
                })

if len(groups_to_create) == 0 and len(missing_from_group) == 0 and len(should_not_be_in_group) == 0:
    print("No changes needed")
    exit()

if len(groups_to_create) > 0:
    print("Adding Groups:")
for group in groups_to_create:
    print(f"    - {group}")

if len(missing_from_group) > 0 or len(should_not_be_in_group) > 0:
    print("\nAuditing Groups:")
for group in groups:
    if group in groups_to_create or any(user['group'] == group for user in missing_from_group) or any(user['group'] == group for user in should_not_be_in_group):
        print(f"  - {group}")
        print("    - Users Missing:")
        for user in missing_from_group:
            if user['group'] == group:
                print(f"      - {user['user']}")
        print("    - Users that should not be in group:")
        for user in should_not_be_in_group:
            if user['group'] == group:
                print(f"      - {user['user']}")

confirm = input("Would you like to continue with these changes? (y/n): ")

if confirm.lower() != "y" and confirm.lower() != "yes":
    exit()

for group in groups_to_create:
    subprocess.run(f"sudo groupadd {group}", shell=True)
    print(f"Created group: {group}")

for user in missing_from_group:
    subprocess.run(f"sudo usermod -aG {user['group']} {user['user']}", shell=True)
    print(f"Added {user['user']} to {user['group']}")

for user in should_not_be_in_group:
    subprocess.run(f"sudo gpasswd -d {user['user']} {user['group']}", shell=True)
    print(f"Removed {user['user']} from {user['group']}")