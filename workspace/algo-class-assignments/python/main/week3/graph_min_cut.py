"""
The file contains the adjacency list representation of a simple undirected graph. There are 40 vertices labeled 1 to 40.
The first column in the file represents the vertex label, and the particular row (other entries except the first column)
tells all the vertices that the vertex is adjacent to. So for example, the 6th row looks likes : "6 29 32 37 27 16".
This just means that the vertex with label 6 is adjacent to (i.e., shares an edge with) the vertices with labels
29, 32, 37, 27 and 16.

Your task is to code up and run the randomized contraction algorithm for the min cut problem and use it
on the above graph to compute the min cut.
(HINT: Note that you'll have to figure out an implementation of edge contractions. Initially,
you might want to do this naively, creating a new graph from the old every time there's an edge contraction.
But you also think about more efficient implementations.)
(WARNING: As per the video lectures, please make sure to run the algorithm many times with different random seeds,
and remember the smallest cut that you ever find).
3
"""
import sys
from random import randint
from copy import deepcopy


class Vertex(object):

    edges = set()
    children = []

    def __init__(self, vertex_id):
        self.vertex_id = vertex_id

    def add_edge(self, edge):
        self.edges.add(edge)

    def set_edges(self, edges):
        self.edges = edges

    def add_child(self, vertex):
        self.children.append(vertex)

    def __eq__(self, another_vertex):
        return self.vertex_id == another_vertex.vertex_id

    def __hash__(self):
        return hash(self.vertex_id)


class Edge(object):

    def __init__(self, first_vertex, second_vertex):
        self.first_vertex = first_vertex
        self.second_vertex = second_vertex

    def vertices(self):
        return self.first_vertex, self.second_vertex

    def contains_both(self, first_vertex, second_vertex):
        return first_vertex in self.vertices() and second_vertex in self.vertices()

    def __eq__(self, another_edge):
        return self.contains_both(another_edge.first_vertex, another_edge.second_vertex)

    def __hash__(self):
        return hash(self.first_vertex) ^ hash(self.second_vertex)


def initialize_input(filename):
    input_vertices = []
    input_edges = []
    file_rows = []

    with open(filename, 'r') as file:
        for line in file:
            row = line.split(" ")
            file_rows.append(row)
            input_vertices.append(Vertex(int(row[0].rstrip())))

    for row in file_rows:
        vertex_id = int(row[0].rstrip())
        first_vertex = next((v for v in input_vertices if v.vertex_id == vertex_id))
        for index, column in enumerate(row):
            if index == 0:
                continue

            second_vertex = next((v for v in input_vertices if v.vertex_id == int(column)))

            edge = next((e for e in input_edges if e.contains_both(first_vertex, second_vertex)), None)
            if not edge:
                edge = Edge(first_vertex, second_vertex)

            first_vertex.add_edge(edge)
            second_vertex.add_edge(edge)

            if edge not in input_edges:
                input_edges.append(edge)

    return input_vertices, input_edges


if len(sys.argv) > 1:
    init_vertices, init_edges = initialize_input(sys.argv[1])
    number_of_runs = len(init_vertices) ** 2

    print("Expected number of runs: " + str(number_of_runs))

    best_min_cut = -1
    for current_run_number in range(number_of_runs):
        vertices = deepcopy(init_vertices)
        edges = deepcopy(init_edges)

        if current_run_number % 100 == 0:
            print("Running for the %s time..." % str(current_run_number + 1))

        ids_for_vertices = 50
        while len(vertices) > 2:
            if len(edges) > 1:
                random_index = randint(0, len(edges) - 1)
            else:
                random_index = 0
            random_edge = edges.pop(random_index)
            first_vertex, second_vertex = random_edge.vertices()

            ids_for_vertices += 1
            composite_vertex = Vertex(ids_for_vertices)
            new_edges = first_vertex.edges.union(second_vertex.edges)

            # Eliminate self-loops
            new_edges = set([e for e in new_edges if not e.contains_both(first_vertex, second_vertex)])
            edges = [e for e in edges if not e.contains_both(first_vertex, second_vertex)]

            # Pointing edges to new composite vertex
            for e in edges:
                if e.first_vertex == first_vertex or e.first_vertex == second_vertex:
                    e.first_vertex = composite_vertex
                if e.second_vertex == first_vertex or e.second_vertex == second_vertex:
                    e.second_vertex = composite_vertex

            composite_vertex.set_edges(new_edges)
            composite_vertex.add_child(first_vertex)
            composite_vertex.add_child(second_vertex)

            if first_vertex in vertices:
                vertices.remove(first_vertex)
            if second_vertex in vertices:
                vertices.remove(second_vertex)
            vertices.append(composite_vertex)

        cur_min_cut = len(edges)
        if best_min_cut == -1 or best_min_cut > cur_min_cut:
            best_min_cut = cur_min_cut

    print("Result best cut is " + str(best_min_cut))
else:
    print("File name should be specified as the only one argument!")
