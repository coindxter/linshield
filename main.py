import argparse
import subprocess



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

    command(['ls', '-l'])
    command(['apt-get','install','aide', 'aide-common'])
    command(['aideinit'])
    command(['mv','/var/lib/aide/aide.db.new','/var/lib/aide/aide.db'])
    command(['chown','root:root','/etc/systemd/system/aidecheck.*' ])

    

