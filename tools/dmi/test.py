import os
import sys

from tools.dmi import *

def _self_test():
    # test: can we load every DMI in the tree
    count = 0
    for dirpath, dirnames, filenames in os.walk('.'):
        if '.git' in dirnames:
            dirnames.remove('.git')
        for filename in filenames:
            if filename.endswith('.dmi'):
                fullpath = os.path.join(dirpath, filename)
                try:
                    Dmi.from_file(fullpath)
                except Exception:
                    print('Failed on:', fullpath)
                    raise
                count += 1

    print(f"{os.path.relpath(__file__)}: successfully parsed {count} .dmi files")


def _usage():
    print(f"Usage:")
    print(f"    tools{os.sep}bootstrap{os.sep}python -m {__spec__.name}")
    exit(1)


def _main():
    if len(sys.argv) == 1:
        return _self_test()

    return _usage()


if __name__ == '__main__':
    _main()
