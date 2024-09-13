from src import cm_debug as deb
import subprocess
import os
import re
import time
import git

class cm_git():
    def __init__(self, **parms):
        self.debug = parms.get("debug", False)
        self.path = parms.get("path", '/tmp/ConfManager/configs')

        if self.debug: deb.cm_debug.show( marker='debGit', message = 'Git repo path: {}'.format(self.path))

        try:
            self.git_repo = git.Repo(self.path)
        except Exception as e:
            if self.debug: deb.cm_debug.show( marker='debGit', message = 'Git is trying to create repo')
            self.git_repo = git.Repo.init(self.path)

        try:
            if self.git_repo.working_tree_dir == self.path:
                if self.debug: deb.cm_debug.show( marker='debGit', message = 'Git Initiated Successfully')
            else:
                if self.debug: deb.cm_debug.show( marker='debGit', message = 'Git NOT Initiated. Exit')
                quit()
        except Exception as e:
            if self.debug: deb.cm_debug.show( marker='debGit', message = 'Git Erro: {} . Exit'.format(e))

    def check(self, **parms):
        after = parms.get("after", False)
        if not self.git_repo.git.status('--short'):
            if self.debug: deb.cm_debug.show( marker='debGit', message = 'Git Nothing to Commit' )
            return False
        if self.debug:
            deb.cm_debug.show( marker='debGit', message = 'Git Commit Available' )
            print(self.git_repo.git.status('--short'))
        if not after:
            self.commit()

    def commit(self, **parms):
        if self.debug: deb.cm_debug.show( marker='debGit', message = 'Git Start Commit' )
        self.git_repo.git.add('-A')
        committer = git.Actor("tacacsgui", "confmanager@localhost")
        self.git_repo.index.commit(message='TacacsGUI',committer=committer)
        self.check(after=True)

    def check_pid(self, pid):
        """ Check For the existence of a unix pid. """
        if not pid: return False
        try:
            os.kill(int(pid), 0)
        except OSError:
            return False
        else:
            return True
