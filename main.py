import argparse
import subprocess
import os


def append_to_file(str, file_name):
    print('appending to file: %s' % file_name)

    ans = input('Do you want to continue? [Y/n]: ')
    if ans not in ('Y', 'y'):
        print('canceling the command')
        return

    # make sure the file exists first
    if not os.path.exists(file_name):
        print('Error - file %s does not exist' % file_name)
        exit()


    # open file in append mode
    f = open(file_name, "a")
    f.write(str)
    f.close()

def command(arguments):
    print(arguments)
    ans = input('Do you want to continue? [Y/n]: ')
    if ans not in ('Y', 'y'):
        print('canceling the command')
        return

    process = subprocess.run(arguments, 
                         stdout=subprocess.PIPE, 
                         universal_newlines=True)
    print(process)


if __name__ == '__main__':
    description_text = '''
    Useful script to help configure Ubuntu machines 
    '''

    example_text = '''
    some example text goes here
    '''

    parser = argparse.ArgumentParser(description=description_text,
                                     epilog=example_text,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument('-v',
                        '--verbose',
                        help='verbose output',
                        default=None)


    #Initialize AIDE
    command(['aideinit'])
    command(['mv','/var/lib/aide/aide.db.new','/var/lib/aide/aide.db'])
    #Ensure permissions on bootloader config are configured correctly
    command(['chown','root:root','/boot/grub/grub.cfg'])
    command(['chmod','u-wx','go-rwx','/boot/grub/grub.cfgs'])
    #Ensure authentication required for a single user mode
    command(['sudo','passwd','root'])
    #Ensure prelink is not installed
    command(['apt','purge','prelink'])
    #Ensure Automatic Error Reporting is disabled
    command(['systemctl','is-active','apport.service'])
    #Ensure permissions on /etc/motd are configured
    command(['chown', 'root:root', '$(readlink -e /etc/motd)'])


    

    #append_to_file('fs.suid_dumpable = 0\n', 'test_file.txt')

