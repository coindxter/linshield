import os
import sys
import re
import requests
import json
import rich
import random


api_key = os.getenv('MISTRAL_API_KEY')
current_user = os.popen('logname').read().strip()
exceptions = ['sync', 'tss', 'whoopsie', 'speech-dispatcher', 'gnome-initial-setup', 'gdm', 'pulse', 'systemd-network', 'systemd-resolve', 'systemd-timesync', 'cups-pk-helper', "daemon", "bin", "sys", "lp", "mail", "www-data", "backup", "syslog", "_apt", "uuidd", "systemd-oom", "tcpdump", "avahi-autoipd", "usbmux", "dnsmasq", "kernoops", "avahi", "rtkit", "sssd", "fwupd-refresh", "nm-openvpn", "saned", "colord", "geoclue", "hplip", "mysql", "postgres", "ftp", current_user]

# check if user is root
if os.geteuid() != 0:
    rich.print("[bold red]You need to have root privileges to run this script.[/bold red]")
    sys.exit(1)

# Functions

def update_file_with_patterns(file_path, patterns_replacements):
    with open(file_path, 'r') as file:
        content = file.readlines()

    added_or_modified = {key: False for key in patterns_replacements}

    modified_content = []
    for line in content:
        for pattern, replacement in patterns_replacements.items():
            if re.match(pattern, line):
                line = re.sub(pattern, replacement, line)
                added_or_modified[pattern] = True
                break
        modified_content.append(line)

    for pattern, replacement in patterns_replacements.items():
        if not added_or_modified[pattern]:
            modified_content.append(replacement + '\n')

    with open(file_path, 'w') as file:
        file.writelines(modified_content)

def find_in_file(file_path, search_pattern):
    with open(file_path, 'r') as file:
        for line_number, line in enumerate(file, start=1):
            if re.search(search_pattern, line):
                return line_number, line.strip()
    return None, None

def append_to_file(file_path, content):
    # check if file exists
    if not os.path.exists(file_path):
        with open(file_path, 'w') as file:
            file.write(content)
        return
    with open(file_path) as f:
        if content in f.read():
            return
    with open(file_path, 'a') as file:
        file.write(content)

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()

def prompt_ai_json(prompt):
    response = requests.post(
        f'https://api.mistral.ai/v1/chat/completions', 
        headers={
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': f'Bearer {api_key}'
        }, json={
        "model": "mistral-large-latest",
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ],
            "response_format": {"type": "json_object"}
        })
    # check if dict response.json()['choices'][0]['message']['content']
    if response.status_code != 200:
        rich.print(f"[bold red]Failed to get response from Mistral AI:[/bold red] [bold green]{response.status_code}[/bold green]")
        rich.print(f"[bold yellow]Response:[/bold yellow]\n\n[bold yellow]{response.text}[/bold yellow]")
        return None
    try:
        opt = response.json()['choices'][0]['message']['content']
        if type(opt) is dict:
            return opt
        return json.loads(opt)
    except Exception as e:
        rich.print(f"[bold red]Failed to parse response from Mistral AI:[/bold red] {e}")
        rich.print(f"[bold yellow]Response:[/bold yellow]\n\n[bold yellow]{response.text}[/bold yellow]")
        return None

def get_etc_passwd_line(username):
    with open('/etc/passwd', 'r') as file:
        for i, line in enumerate(file.readlines()):
            if line.startswith(username + ':'):
                return line.strip(), i
    return None

def update_etc_passwd_line(username, new_line):
    with open('/etc/passwd', 'r') as file:
        lines = file.readlines()
    with open('/etc/passwd', 'w') as file:
        for line in lines:
            if line.startswith(username + ':'):
                file.write(new_line + '\n')
            else:
                file.write(line)

def get_net_best_uid():
    with open('/etc/passwd', 'r') as file:
        lines = file.readlines()
    uid = 0
    for line in lines:
        if int(line.split(':')[2]) > uid:
            uid = int(line.split(':')[2])
    return uid + 1

# Script

update_file_with_patterns('/etc/login.defs', {
    r'^PASS_MAX_DAYS.*': 'PASS_MAX_DAYS 30',
    r'^PASS_MIN_DAYS.*': 'PASS_MIN_DAYS 7',
    r'^PASS_WARN_AGE.*': 'PASS_WARN_AGE 14',
    r'^LOGIN_RETRIES.*': 'LOGIN_RETRIES 3',
    r'^LOGIN_TIMEOUT.*': 'LOGIN_TIMEOUT 60'
})

if find_in_file('/etc/login.defs', r'^ENCRYPT_METHOD.*')[1]:
    update_file_with_patterns('/etc/login.defs', {
        r'^ENCRYPT_METHOD.*': 'ENCRYPT_METHOD SHA512'
    })
else:
    append_to_file('/etc/login.defs', 'ENCRYPT_METHOD SHA512')

etc_passwd_content = read_file('/etc/passwd')
usersByCategory = prompt_ai_json("""You are provided with the content of the `/etc/passwd` file. Your task is to parse this file and categorize the users into three categories: `system_accounts`, `root_imposters`, and `users`.

- `system_accounts`: Users with UID less than 1000 but not equal to 0.
- `root_imposters`: Users with UID equal to 0 who are not the `root` account.
- `users`: Users with UID greater than or equal to 1000.

The content of the `/etc/passwd` file is as follows:

```plaintext
""" + etc_passwd_content + """
```

Parse the file and generate a JSON array with the categorized users. The JSON array should have the following structure:

```json
{
    "system_accounts": [
        "username1",
        "username2",
        ...
    ],
    "root_imposters": [
        "username1",
        "username2",
        ...
    ],
    "users": [
        "username1",
        "username2",
        ...
    ]
}
```

Please provide the JSON array based on the given `/etc/passwd` file content.
```

### Example Input

Here's an example of how you might provide the content of the `/etc/passwd` file as input:

```plaintext
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
the_bad_user:x:0:0:root:/root:/bin/bash
systemd-network:x:100:101:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:101:102:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin
systemd-timesync:x:102:103:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
messagebus:x:103:104::/nonexistent:/usr/sbin/nologin
sshd:x:104:65534::/run/sshd:/usr/sbin/nologin
user1:x:1000:1000:User One:/home/user1:/bin/bash
user2:x:1001:1001:User Two:/home/user2:/bin/bash
```

### Expected Output

Based on the provided input, the expected JSON output would be:

```json
{
    "system_accounts": [
        "daemon",
        "bin",
        "sys",
        "sync",
        "games",
        "man",
        "lp",
        "mail",
        "news",
        "uucp",
        "proxy",
        "www-data",
        "backup",
        "list",
        "irc",
        "gnats",
        "nobody",
        "systemd-network",
        "systemd-resolve",
        "systemd-timesync",
        "messagebus",
        "sshd"
    ],
    "root_imposters": [
        "the_bad_user"
    ],
    "users": [
        "user1",
        "user2"
    ]
}
```
""")

for user in usersByCategory['system_accounts']:
    line, line_number = get_etc_passwd_line(user)
    if user.lower().strip() not in exceptions:
        rich.print(f"[cyan]Locking system account for[/cyan] [bold pink]{user}[/bold pink]")
        os.system(f"usermod -L {user}")
    if user.lower().strip() not in exceptions:
        if "nologin" not in line:
            rich.print(f"[cyan]Changing shell for[/cyan] [bold pink]{user}[/bold pink] [cyan]to[/cyan] [yellow]/usr/sbin/nologin[/yellow]")
            line = line.split(':')
            line[-1] = '/bin/false'
            line = ':'.join(line)
            update_etc_passwd_line(user, line)

for user in usersByCategory['root_imposters']:
    if input(f"Would you like to disable the user {user}? [y/N]: ").lower() == 'y':
        rich.print(f"[cyan]Disabling user[/cyan] [bold pink]{user}[/bold pink]")
        os.system(f"usermod -L {user}")
    if input(f"Would you like to set a new UID for {user}? [y/N]: ").lower() == 'y':
        new_uid = get_net_best_uid()
        rich.print(f"[cyan]Setting new UID for user[/cyan] [bold pink]{user}[/bold pink] [cyan]to[/cyan] [yellow]{new_uid}[/yellow]")
        line, line_number = get_etc_passwd_line(user)
        line = line.split(':')
        line[2] = str(new_uid)
        line = ':'.join(line)
        update_etc_passwd_line(user, line)

usersByCategory['users'].append('root')

for user in usersByCategory['users']:
    if user in exceptions:
        if user != 'root':
            rich.print(f"[bold red]Skipping password change on {user}[/bold red]")
            continue
    rand_pass = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', k=16))
    rich.print(f"[cyan]Setting random password for user[/cyan] [bold pink]{user}[/bold pink]")
    os.system(f"echo '{user}:{rand_pass}' | chpasswd")
    append_to_file('passwords.txt', f"{user} : {rand_pass}\n")

usersByCategory['users'].remove('root')

# Set individual user login settings (min, max, warn ages)
for user in usersByCategory['users']:
    if user in exceptions:
        continue
    pattern = r'^{}:'.format(re.escape(user))
    try:
        with open("/etc/shadow", 'r') as file:
            lines = file.readlines()
        updated_lines = []
        for line in lines:
            if re.match(pattern, line):
                # Modify the line as per the sed command
                modified_line = re.sub(r'([^:]*:[^:]*:[^:]*:)[^:]*:[^:]*:[^:]*:([^:]*)',
                                       r'\1 7:90:14:\2', line)
                updated_lines.append(modified_line)
            else:
                updated_lines.append(line)
        with open("/etc/shadow", 'w') as file:
            file.writelines(updated_lines)
        rich.print(f"[cyan]Updated password settings for user[/cyan] [bold pink]{user}[/bold pink]")
    except Exception as e:
        rich.print(f"[bold red]Failed to update password settings for user {user}:[/bold red] {e}")

if input("Would you like to configure PAM? [y/N]: ").lower() != 'y':
    sys.exit(0)

os.system("apt install libpam-pwquality -y")
os.system("apt install --reinstall libpam-modules -y")

update_file_with_patterns('/etc/pam.d/common-password', {
    r'pam_pwquality.so': 'pam_pwquality.so retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 minclass=3 maxrepeat=2 enforce_for_root gecoscheck=1 dictcheck=1'
})
rich.print("[bold green]Added checks similar to gecos and dictcheck, with complexitry rules[/bold green]")

update_file_with_patterns('/etc/pam.d/common-password', {
    r'pam_unix.so': 'pam_unix.so rounds=8000 shadow remember=7'
})
rich.print("[bold green]Updated password hashing to SHA512 with 8000 rounds and added password history[/bold green]")

append_to_file('/etc/pam.d/common-auth', 'auth required pam_tally2.so audit silent deny=5 unlock_time=900')
rich.print("[bold green]Added account lockout policy[/bold green]")

update_file_with_patterns('/etc/pam.d/common-auth', {
    r'nullok': ''
})
update_file_with_patterns('/etc/pam.d/common-password', {
    r'nullok': ''
})
rich.print("[bold green]Removed null password auth from common-auth and common-password[/bold green]")

update_file_with_patterns('/etc/profile', {
    r'^TMOUT.*': 'TMOUT=600',
    r'^readonly TMOUT.*': 'readonly TMOUT',
    r'^export TMOUT.*': 'export TMOUT'
})
rich.print("[bold green]Set session timeout to 10 minutes[/bold green]")

update_file_with_patterns('/etc/profile', {
    r'^umask.*': ''
})
append_to_file('/etc/profile', 'umask 027')
rich.print("[bold green]Set default umask to 027[/bold green]")

append_to_file('/etc/pam.d/common-auth', 'auth required pam_tally2.so file=/var/log/tallylog deny=5 even_deny_root unlock_time=900')
rich.print("[bold green]Added account lockout policy[/bold green]")
