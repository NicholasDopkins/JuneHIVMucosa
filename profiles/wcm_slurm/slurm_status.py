#! /usr/bin/env python
from __future__ import print_function
from builtins import str

import sys
import re
import subprocess
from subprocess import check_output, Popen, PIPE, CalledProcessError
import shlex
import re

FAILED_STATE = 'failed'
RUNNING_STATE = 'running'
COMPLETED_STATE = 'success'
DEFAULT_STATE = RUNNING_STATE

# Slurm states
SLURM_TO_STATE = {
    'COMPLETED': 'success',
    'FAILED': 'failed',
    'CANCELLED': 'failed',
    'TIMEOUT': 'failed',
    'PREEMPTED': 'failed',
    'NODE_FAIL': 'failed',
    
    'PENDING': 'running',
    'RUNNING': 'running',
    'SUSPENDED': 'running',
    'COMPLETING': 'running',
    'CONFIGURING': 'running',
    'REQUEUED': 'running',

    'REVOKED': 'failed',
    'SPECIAL_EXIT': 'failed',
}

def jobstatus(jobid):
    try:
        o,e = Popen('sacct -u $(whoami) -nXPo state -j ' + sys.argv[1],
                    shell=True, stdout=PIPE, stderr=PIPE).communicate()
        ret = '{}'.format(str(o, 'utf-8').split()[0])
        if ret in SLURM_TO_STATE:
            return (SLURM_TO_STATE[ret], ret)
        else:
            print('Unknown slurm state: {}'.format(ret), file=sys.stderr)
            return (DEFAULT_STATE, ret)
    except Exception as e:
        print(e, file=sys.stderr)
        return (DEFAULT_STATE, None)

def jobstatus_scontrol(jobid):
    try:
        sctrl_res = check_output(
            shlex.split(f"scontrol -o show job %s" % jobid),
            stderr=subprocess.STDOUT,
        )
        m = re.search(r"JobState=(\w+)", sctrl_res.decode())
        ret = m.group(1)
        if ret in SLURM_TO_STATE:
            return (SLURM_TO_STATE[ret], ret)
        else:
            print('Unknown slurm state: {}'.format(ret), file=sys.stderr)
            return (DEFAULT_STATE, ret)
    except CalledProcessError as e:
        if e.returncode == 1 and re.search('Invalid job id specified', e.output.decode()):
            print('Invalid job id: %s' % jobid, file=sys.stderr)
            return (FAILED_STATE, None)
        return (DEFAULT_STATE, None)        
    except Exception as e:
        print(e, file=sys.stderr)
        return (DEFAULT_STATE, None)


if __name__ == '__main__':
    jobid = sys.argv[1].strip()
    if not re.match('\d+', jobid):
        print("Argument is not job ID: {}".format(jobid), file=sys.stderr)
        print(DEFAULT_STATE)
    else:
        state, ret = jobstatus_scontrol(jobid)
        print(state)
