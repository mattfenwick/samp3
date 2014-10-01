import json


def load(path='../sparky_data.json'):
    with open(path, 'r') as file:
        my_model = json.loads(file.read())
    return my_model


def get_shifts(model):
    shifts = [{} for _ in range(107)]
    for (gid, grp) in model['groups'].items():
        try:
            ix = int(grp['residue'])
            prev = ix - 1
        except ValueError: # if the group isn't assigned to a residue
            print 'skipping', gid
            continue
        for (rid, r) in grp['resonances'].items():
            for atoms in r['atomtype'].split('/'):
                if atoms[-5:] == '(i-1)':
                    at = atoms[:-5]
                    index = prev
                else:
                    at = atoms
                    index = ix
                if not at in shifts[index]:
                    shifts[index][at] = []
                shifts[index][at].append(r['shift'])
    return shifts


def format_shifts(model):
    seq = 'GGGRDYKDDDDKGTMELELRFFATFREVVGQKSIYWRVDDDATVGDVLRSLEAEYDGLAGRLIEDGEVKPHVNVLKNGREVVHLDGMATALDDGDAVSVFPPVAGG'
    shifts = []
    for (ix, residue) in enumerate(get_shifts(model)):
        for (a, vals) in residue.items():
            if a == '?':
                continue
            if len(vals) > 1:
                s = sorted(vals)
                if abs(s[0] - s[-1]) > 0.1:
                    pass # print ValueError(str((ix, a, vals)))
            shifts.append({
                'residue' : ix,
                'atomtype': a,
                'shifts'  : vals,
                'shift'   : sum(vals) / len(vals),
                'aatype'  : seq[ix - 1]
            })
    return shifts


def talos_output(model):
    shifts = format_shifts(model)
    out = []
    for s in shifts:
        my_str = "%4i %1s %6s  %8.3f" % (s['residue'], s['aatype'], 
                                         s['atomtype'], s['shift'])
        out.append(my_str)
    return out


def cyana_output(model):
    shifts = format_shifts(model)
    out = []
    for (ix, s) in enumerate(shifts, start=1):
        my_str = "%4s %7.3f 0.000 %-4s %3s" % (ix, s['shift'],
                                               s['atomtype'], s['residue'])
        out.append(my_str)
    return out
