import numpy as np
import matplotlib.pyplot as plt
import sys
import random

from sklearn.preprocessing import scale
from scipy.spatial import Voronoi
from heapq import heappop, heappush
from scipy.spatial.distance import cdist

from lib.sammon import sammon
from lib.min_bounding_rect import minBoundingRect
from lib.qhull_2d import qhull2D


make_a_plot = True
max_it = 10


def pull_points(points, grav_points, mass, g):
    dists = cdist(points, grav_points) +1
    force = g * mass / dists**2
    diffs = grav_points[:, np.newaxis] - points[np.newaxis]
    lengths = np.sqrt((diffs**2).sum(axis=2))
    lengths[lengths == 0] = 1
    diffs /= lengths[:, :, np.newaxis]
    movements = (diffs * force.T[:, :, np.newaxis]).sum(axis=0)
    return points + movements


def make_grav_points(points_per_edge, xlim=(-2,2), ylim=(-2,2), grid=False):
    lx = np.linspace(xlim[0], xlim[1], points_per_edge)[:, np.newaxis]
    ly = np.linspace(ylim[0], ylim[1], points_per_edge)[:, np.newaxis]

    if grid:
        xx, yy = np.meshgrid(lx, ly)
        grid = np.concatenate([xx[:,:,np.newaxis], yy[:,:,np.newaxis]], axis=2).reshape(-1,2)
        return grid

    else:
        pt1 = np.hstack([lx, np.ones_like(lx)*ylim[0]])
        pt2 = np.hstack([lx, np.ones_like(lx)*ylim[1]])
        pt3 = np.hstack([np.ones_like(ly)*ylim[0], ly])[1:-1]
        pt4 = np.hstack([np.ones_like(ly)*ylim[1], ly])[1:-1]
        return np.vstack([pt1, pt2, pt3, pt4])


def load_graph(path):
    n = None
    graph = {}
    sizes = {}
    with open(path, 'r') as f:
        it = 0
        for line in f:
            l = line.split()
            if n is None:
                n = int(l[0])
            else:
                Id = l[0]
                sizes[Id] = int(l[1])
                graph[Id] = l[2:]
            it += 1
        assert n + 1 == it
        assert len(graph) == n
    return graph, sizes


def same_vert(a,b):
    return a.split('_')[0] == b.split('_')[0]


def vert_id(a):
    return a.split('_')[0]


def reshape_graph(graph, sizes):

    def vert(a,b):
        return str(a) + '_' + str(b)

    n = len(sizes)
    new_graph = {}
    for v in graph:
        for k in range(1, sizes[v] + 1):
            new_graph[vert(v,k)] = []

    done = set()

    for v in graph:
        for u in graph[v]:
            if (v, u) not in done:
                v_ = vert(v, random.choice(range(1, sizes[v] + 1)))
                u_ = vert(u, random.choice(range(1, sizes[u] + 1)))
                new_graph[v_].append(u_)
                new_graph[u_].append(v_)
                done |= {(v, u), (u, v)}

    for v in graph:
        if sizes[v] > 1:
            for k in range(1, sizes[v] + 1):
                u1 = vert(v, k)
                u2 = vert(v, (k % sizes[v]) + 1)
                new_graph[u1].append(u2)
                new_graph[u2].append(u1)

    return new_graph


def squeeze(data, xlim=(0,1), ylim=(0,1)):
    xmi = min(data[:,0].ravel())
    xma = max(data[:,0].ravel()) - xmi

    ymi = min(data[:,1].ravel())
    yma = max(data[:,1].ravel()) - ymi

    new_data = data.copy()
    new_data[:,0] = (new_data[:,0] - xmi) / xma
    new_data[:,1] = (new_data[:,1] - ymi) / yma
    new_data[:,0] = new_data[:,0] * (xlim[1]-xlim[0]) + xlim[0]
    new_data[:,1] = new_data[:,1] * (ylim[1]-ylim[0]) + ylim[0]
    return new_data


def make_index(graph):
    temp = list(enumerate(sorted(graph.keys(), key=lambda x: tuple(x.split('_')))))
    return dict(temp), {v:k for (k,v) in temp}


def calc_weights(graph, sizes):
    ws = {}
    for v in graph:
        for u in graph:
            if v != u:
                ws[(u,v)] = len(set(graph[u]).union(graph[v])) - \
                    len(set(graph[u]).intersection(graph[v]))
#                 uid, vid = vert_id(u), vert_id(v)
#                 ws[(u,v)] *= np.sqrt((sizes[uid] + sizes[vid]) / 2)
    return ws


def dijksta(graph, weights, v1, v2):
    Q = [(0, v1)]
    seen = set()

    while Q:
        w, v = heappop(Q)
        if v not in seen:
            seen.add(v)
            if v == v2:
                return w

            for u in graph[v]:
                if u not in seen:
                    heappush(Q, (w + weights[(v,u)], u))

    return float('inf')


def calc_dists(graph, weights, idx):
    n = len(graph)
    dists = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = dijksta(graph, weights, idx[i], idx[j])
            dists[i,j] = d
    return dists + dists.T


def plot_a_thing(data, graph, inds, vor, vor_zone_graph, cons, figname=None, to_file=True,
                 xlim=(-2,2), ylim=(-2,2), threshold=.5):
    assert not to_file or figname

    bad_edges = 0
    plt.figure(figsize=(10,10))
    plt.scatter(data[:,0], data[:,1], linewidths=.2, s=10)
    for u_num in range(data.shape[0]):
        plt.text(data[u_num][0], data[u_num][1], inds[0][u_num], color="red", fontsize=8)
        u = inds[0][u_num]

        for v in graph[u]:
            v_num = inds[1][v]

            x1 = data[u_num][0], data[v_num][0]
            x2 = data[u_num][1], data[v_num][1]

            if u_num < v_num or same_vert(v, u):
                if same_vert(v, u):
                    same = plt.plot(x1, x2)
                    c = 'k' if cons[vert_id(v)] else 'r'
                    plt.setp(same, linewidth=.5, color=c)
                elif vert_id(v) not in vor_zone_graph[vert_id(u)]:
                    bad = plt.plot(x1, x2)
                    plt.setp(bad, linewidth=3, color='r')
                    bad_edges += 1
                else:
                    ok = plt.plot(x1, x2)
                    plt.setp(ok, linewidth=3, color='g')


    vert_mapping = list(enumerate(set((vert_id(v) for v in inds[1]))))
    real_ind = {v:k for (k,v) in vert_mapping}
    means = [[] for i in range(len(real_ind))]
    for v in inds[1]:
        means[real_ind[vert_id(v)]].append(data[inds[1][v]])
    means = np.array([np.mean(l, axis=0) for l in means])

    plt.scatter(means[:,0], means[:,1], linewidths=.2, s=30)
    for v in real_ind:
        i = real_ind[v]
        plt.text(means[i,0], means[i,1], v, color="blue", fontsize=14)


    plt.xlim(*xlim)
    plt.ylim(*ylim)

    i = 0
    for simplex_idx in range(len(vor.ridge_vertices)):
        simplex = np.asarray(vor.ridge_vertices[simplex_idx])
        if np.all(simplex >= 0):
            a, b = vor.ridge_points[simplex_idx]
            if not same_vert(inds[0][a], inds[0][b]):
                plt.plot(vor.vertices[simplex,0], vor.vertices[simplex,1], 'k--')
        i += 1

    center = data.mean(axis=0)
    for pointidx, simplex_idx in zip(vor.ridge_points, range(len(vor.ridge_vertices))):
        simplex = np.asarray(vor.ridge_vertices[simplex_idx])
        a, b = vor.ridge_points[simplex_idx]
        if np.any(simplex < 0) and not same_vert(inds[0][a], inds[0][b]):
            i = simplex[simplex >= 0][0] # finite end Voronoi vertex
            t = data[pointidx[1]] - data[pointidx[0]] # tangent
            t /= np.linalg.norm(t)
            norm = np.array([-t[1], t[0]]) # normal
            midpoint = data[pointidx].mean(axis=0)
            far_point = vor.vertices[i] + np.sign(np.dot(midpoint - center, norm)) * norm * 100
            plt.plot([vor.vertices[i,0], far_point[0]], [vor.vertices[i,1], far_point[1]], 'k--')

    plt.text(xlim[1]-4, ylim[1]+.1, 'Bad edges: ' + str(bad_edges), color="red", fontsize=20)
    plt.text(xlim[1]-2, ylim[1]+.1, 'Inconsistent zones: ' + str(len(cons) - sum(cons.values())),
             color="red", fontsize=20)

    step = 0.05
    x = np.arange(xlim[0], xlim[1] + step, step)
    y = np.arange(ylim[0], ylim[1] + step, step)
    xx, yy = np.meshgrid(x, y)
    grid = np.concatenate([xx[:,:,np.newaxis], yy[:,:,np.newaxis]], axis=2).reshape(-1,2)
    min_grid_dists = cdist(grid, data).min(axis=1)
    grey_out = grid[np.where(min_grid_dists > threshold)]
    plt.plot(grey_out[:,0], grey_out[:,1], 'kx')

    if to_file:
        plt.savefig(figname)


def save_embedding(data, idx, fname):
    if not fname.endswith('.txt'):
        fname += '.txt'
    with open(fname, 'w') as f:
        f.write(str(len(idx)) + '\n')
        for i in range(len(idx)):
            x, y = data[i]
            f.write(str(vert_id(idx[i])) + ' ' + str(x) + ' ' + str(y) + ' 1 0\n')


def prepare_voronoi(graph, sizes, data):
    vor = Voronoi(data)
    vor_graph = {inds[0][n] : [] for n in range(len(graph))}

    for i, j in vor.ridge_points:
        vor_graph[inds[0][i]].append(inds[0][j])
        vor_graph[inds[0][j]].append(inds[0][i])

    vor_zone_graph = {v : set() for v in sizes}

    for key, value in vor_graph.items():
        vor_zone_graph[vert_id(key)] |= {vert_id(v) for v in value if vert_id(v) != vert_id(key)}

    return vor, vor_graph, vor_zone_graph


def zone_consistency(vor_graph, sizes):
    cons = {v : True for v in sizes}

    def accessible_same_id(wid):
        w1 = wid + '_1'
        acc = {w1}
        acc_new = {v for v in vor_graph[w1] if vert_id(v) == wid}
        while acc_new:
            acc |= acc_new
            acc_new = {v for u in acc_new for v in vor_graph[u] if vert_id(v) == wid} - acc
        return len(acc) == sizes[wid]

    for v in cons:
        cons[v] = accessible_same_id(v)

    return cons


def calc_bad_edges(graph, vor_zone_graph):
    bad_edges = 0
    for u in graph:
        for v in graph[u]:
            if not same_vert(v, u) and vert_id(v) not in vor_zone_graph[vert_id(u)]:
                bad_edges += 1
    return bad_edges / 2


if __name__ == '__main__':

    path = sys.argv[1]
    if len(sys.argv) > 2:
        output_fname = sys.argv[2]
    else:
        output_fname = path + '_emb'

    graph, sizes = load_graph(path)
    graph = reshape_graph(graph, sizes)
    inds = make_index(graph)
    weights = calc_weights(graph, sizes)
    dists = calc_dists(graph, weights, inds[0])

    xlim=(-2.5,2.5)
    ylim=(-2.5,2.5)
    xlim_grav = (-2.2,2.2)
    ylim_grav = xlim_grav

    def embed():
        data_trans, E = sammon(dists, inputdist='distance', init='random', display=0)

        data_trans_scaled = squeeze(data_trans, xlim, ylim)
        data_trans_scaled = scale(data_trans)

        ch = qhull2D(data_trans_scaled)
        theta, _, width, height, _, _ = minBoundingRect(ch)
        R = np.array([[np.cos(theta), -np.sin(theta)], [np.sin(theta), np.cos(theta)]])

        data_trans_scaled = data_trans_scaled.dot(R)
        data_trans_scaled[:, 0] *= height / width
        data_trans_scaled = squeeze(data_trans_scaled, xlim_grav, ylim_grav)

        # improving the embeddings with 'gravity'
        grav_points = make_grav_points(points_per_edge=6, xlim_grav, ylim_grav, grid=False)

        # 10 iterations, can be changed
        for i in range(10):
            mass = cdist(grav_points, data_trans_scaled).min(axis=1)
            data_trans_scaled = pull_points(data_trans_scaled, grav_points, mass, .5)

        vor, vor_graph, vor_zone_graph = prepare_voronoi(graph, sizes, data_trans_scaled)
        cons = zone_consistency(vor_graph, sizes)
        bad_zones = len(cons) - sum(cons.values())
        bad_edges = calc_bad_edges(graph, vor_zone_graph)

        return data_trans_scaled, vor, vor_zone_graph, cons, E, bad_edges, bad_zones


    best_sol = None
    best_loss = np.inf, np.inf, np.inf
    print("Testing %i embeddings..." % max_it)
    print("inconsistent zones, bad edges, embedding loss")
    for i in range(max_it):
        sol, vor, vor_zone_graph, cons, E, bad_edges, bad_zones = embed()
        loss = bad_zones, bad_edges, E
        print(loss)
        if loss < best_loss:
            best_loss = loss
            best_sol = sol, vor, vor_zone_graph, cons

    bad_edges, bad_zones = best_loss[:2]
    sol, vor, vor_zone_graph, cons = best_sol
    print("Best: %s" % str(best_loss))

    if make_a_plot:
        plot_a_thing(sol, graph, inds, vor, vor_zone_graph, cons,
                     xlim=xlim, ylim=ylim, threshold=.5, figname=output_fname + '.png')

    save_embedding(sol, inds[0], output_fname)

