import argparse
import subprocess


def append_to_file(str, file_name):
    print('appending: %s' % str)
    print('to file: %s' % file_name)

    ans = input('Do you want to continue? [Y/n]: ')
    if ans not in ('Y', 'y'):
        print('canceling the command')
        return

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

    #command(['ls', '-l'])
    #command(['apt-get','install','aide', 'aide-common'])
    #command(['aideinit'])
    #command(['mv','/var/lib/aide/aide.db.new','/var/lib/aide/aide.db'])
    #command(['chown','root:root','/etc/systemd/system/aidecheck.*' ])

    append_to_file('fs.suid_dumpable = 0\n', 'test_file.txt')

