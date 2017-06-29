import numpy as np
import matplotlib.pyplot as plt
import sys, random

from sklearn.preprocessing import scale
from sklearn.manifold import MDS
from scipy.spatial import Voronoi, voronoi_plot_2d
from heapq import heappop, heappush
from scipy.spatial.distance import cdist
from collections import defaultdict as dd

from lib.sammon import sammon
from lib.min_bounding_rect import minBoundingRect
from lib.qhull_2d import qhull2D


def pull_points(points, grav_points, mass, g):
    dists = cdist(points, grav_points) +1
    force = g * mass / dists**2
    diffs = grav_points[:, np.newaxis] - points[np.newaxis]
    lengths = np.sqrt((diffs**2).sum(axis=2))
    lengths[lengths == 0] = 1
    diffs /= lengths[:, :, np.newaxis]
    movements = (diffs * force.T[:, :, np.newaxis]).sum(axis=0)
    return points + movements


def make_grav_points(gap, xlim=(-2,2), ylim=(-2,2), grid=False):
    lx = np.arange(xlim[0], xlim[1] + gap, gap)[:, np.newaxis]
    ly = np.arange(ylim[0], ylim[1] + gap, gap)[:, np.newaxis]
    
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


def plot_a_thing(data_trans, graph, inds, figname=None, to_file=True, 
                 xlim=(-2,2), ylim=(-2,2), threshold=.5):
    assert not to_file or figname
    
    vor = Voronoi(data_trans)

    reds = 0
    plt.figure(figsize=(10,10))
    plt.scatter(data_trans[:,0], data_trans[:,1], linewidths=.2, s=10)
    for i in range(data_trans.shape[0]):
        plt.text(data_trans[i][0], data_trans[i][1], inds[0][i], color="red", fontsize=8)
        for k in graph[inds[0][i]]:
            j = inds[1][k]
            if i < j or same_vert(k, inds[0][i]):
                if np.where(np.all(np.array([i,j]) == vor.ridge_points, axis=1))[0].shape == (0,) and \
                   np.where(np.all(np.array([j,i]) == vor.ridge_points, axis=1))[0].shape == (0,) and \
                    not same_vert(inds[0][i], k):
                    plt.plot((data_trans[i][0], data_trans[j][0]),
                             (data_trans[i][1], data_trans[j][1]), 'r-')
                    reds += 1
                else:
                    plt.plot((data_trans[i][0], data_trans[j][0]),
                             (data_trans[i][1], data_trans[j][1]), 'g-')
    
    
    vert_mapping = list(enumerate(set((vert_id(v) for v in inds[1]))))
    real_ind = {v:k for (k,v) in vert_mapping}
    means = [[] for i in range(len(real_ind))]
    for v in inds[1]:
        means[real_ind[vert_id(v)]].append(data_trans[inds[1][v]])
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

    center = data_trans.mean(axis=0)
    for pointidx, simplex_idx in zip(vor.ridge_points, range(len(vor.ridge_vertices))):
        simplex = np.asarray(vor.ridge_vertices[simplex_idx])
        a, b = vor.ridge_points[simplex_idx]
        if np.any(simplex < 0) and not same_vert(inds[0][a], inds[0][b]):
            i = simplex[simplex >= 0][0] # finite end Voronoi vertex
            t = data_trans[pointidx[1]] - data_trans[pointidx[0]] # tangent
            t /= np.linalg.norm(t)
            norm = np.array([-t[1], t[0]]) # normal
            midpoint = data_trans[pointidx].mean(axis=0)
            far_point = vor.vertices[i] + np.sign(np.dot(midpoint - center, norm)) * norm * 100
            plt.plot([vor.vertices[i,0], far_point[0]], [vor.vertices[i,1], far_point[1]], 'k--')

    plt.text(xlim[1]-1, ylim[1]+.1, 'Bad edges: ' + str(reds), color="red", fontsize=20)
    
    step = 0.05
    x = np.arange(xlim[0], xlim[1] + step, step)
    y = np.arange(ylim[0], ylim[1] + step, step)
    xx, yy = np.meshgrid(x, y)
    grid = np.concatenate([xx[:,:,np.newaxis], yy[:,:,np.newaxis]], axis=2).reshape(-1,2)
    min_grid_dists = cdist(grid, data_trans).min(axis=1)
    grey_out = grid[np.where(min_grid_dists > threshold)]
    plt.plot(grey_out[:,0], grey_out[:,1], 'kx')
    
    if to_file:
        plt.savefig(figname)


def save_embedding(data_trans, idx, fname):
    if not fname.endswith('.txt'):
        fname += '.txt'
    with open(fname, 'w') as f:
        f.write(str(len(idx)) + '\n')
        for i in range(len(idx)):
            x, y = data_trans[i]
            f.write(str(vert_id(idx[i])) + ' ' + str(x) + ' ' + str(y) + ' 1 0\n')


if __name__ == '__main__':
    
    path = sys.argv[1]
    if len(sys.argv) > 2:
        output_fname = sys.argv[2]
    else:
        output_fname = path + '_emb'
        
    mode = 'sammon'
    
    graph, sizes = load_graph(path)
    graph = reshape_graph(graph, sizes)
    inds = make_index(graph)
    weights = calc_weights(graph, sizes)
    dists = calc_dists(graph, weights, inds[0])
    
    if mode == 'sammon':
        data_trans = sammon(dists, inputdist='distance', init='random', display=0)[0]
    elif mode == 'mds':
        mds = MDS(n_components=2, metric=True, dissimilarity='precomputed', 
                  n_init=10, max_iter=100000, eps=.00001)
        data_trans = mds.fit_transform(dists)
    
    xlim=(-2.5,2.5)
    ylim=(-2.5,2.5)
    data_trans_scaled = squeeze(data_trans, xlim, ylim)
    data_trans_scaled = scale(data_trans)
    
    ch = qhull2D(data_trans_scaled)
    theta, _, width, height, _, _ = minBoundingRect(ch)
    R = np.array([[np.cos(theta), -np.sin(theta)], [np.sin(theta), np.cos(theta)]])

    data_trans_scaled = data_trans_scaled.dot(R)
    data_trans_scaled[:, 0] *= height / width
    data_trans_scaled = squeeze(data_trans_scaled, (xlim[0]+.5, xlim[1]-.5), (ylim[0]+.5, ylim[1]-.5))
    
    plot_a_thing(data_trans_scaled, graph, inds, figname=output_fname + '_pregrav.png', 
                 xlim=xlim, ylim=ylim, threshold=.5)
    
    save_embedding(data_trans_scaled, inds[0], output_fname + '_pregrav')
    
    # improving the embeddings with 'gravity'
    
    xlim_grav = (-2.,2.)
    ylim_grav = xlim_grav
    grav_points = make_grav_points(1, xlim_grav, ylim_grav, grid=False)

    # 10 iterations, can be changed    
    for i in range(10):
        mass = cdist(grav_points, data_trans_scaled).min(axis=1)
        data_trans_scaled = pull_points(data_trans_scaled, grav_points, mass, .5)
        
    plot_a_thing(squeeze(data_trans_scaled, xlim_grav, ylim_grav), graph, inds, 
                 xlim=xlim, ylim=ylim, threshold=.5, figname=output_fname + '.png')
    
    save_embedding(data_trans_scaled, inds[0], output_fname)
    
