import argparse
import subprocess
import os

def insert_in_file(insert_str, file_name, search_str):
    with open(file_name, 'r+') as fd:
        contents = fd.readlines()

        if search_str in contents[-1]:  # Handle last line to prevent IndexError
            contents.append(insert_str)
        else:
            for index, line in enumerate(contents):
                if search_str in line:
                    contents.insert(index + 1, insert_str)
                    break
        fd.seek(0)
        fd.writelines(contents)


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



    


    
#    insert_in_file('*****\n', r"/Users/jaredcrace/data/tasks/owen_prj/owen_new_prj/Ubuntu_Script/src/test_file.txt", 'three')
    insert_in_file('dog\n', 'test_file.txt', 'test_marker')

    #append_to_file('fs.suid_dumpable = 0\n', 'test_file.txt')

