# The file contains the adjacency list representation of a simple undirected graph. There are 40 vertices labeled 1 to 40. 
# The first column in the file represents the vertex label, and the particular row (other entries except the first column) 
# tells all the vertices that the vertex is adjacent to. So for example, the 6th row looks likes : "6 29 32 37 27 16". 
# This just means that the vertex with label 6 is adjacent to (i.e., shares an edge with) the vertices with labels 29, 32, 37, 27 and 16.
#
# Your task is to code up and run the randomized contraction algorithm for the min cut problem and use it on the above graph to compute the min cut. 
# (HINT: Note that you'll have to figure out an implementation of edge contractions. Initially, you might want to do this naively, creating a new graph
# from the old every time there's an edge contraction. But you also think about more efficient implementations.) 
#
# (WARNING: As per the video lectures, please make sure to run the algorithm many times with different random seeds, 
# and remember the smallest cut that you ever find). 

def initialize_input(filename)
  input_vertices = []
  input_edges = []
  file_rows = []
  
  File.open(filename, 'r') do |file|
    while line = file.gets
      row = line.split(" ")
      file_rows.push row
      vertex = Vertex.new(row[0].to_i)
      input_vertices.push vertex
    end
  end
  
  file_rows.each do |row|
    vertex_id = row[0].to_i
    first_vertex = input_vertices.find { |v| v.vertex_id == vertex_id }
    row.each_with_index do |column, index|
      if index == 0
        next
      end
      
      v_id = column.to_i
      second_vertex = input_vertices.find { |v| v.vertex_id == v_id }
      
      edge = input_edges.find { |item| item.contains_both_vertices?(first_vertex, second_vertex) }
      unless edge
        edge = Edge.new(first_vertex, second_vertex)
      end
      
      first_vertex.add_edge edge
      second_vertex.add_edge edge
      
      unless input_edges.include? edge
        input_edges.push edge
      end
      
    end
  end
  
  return input_vertices, input_edges
end

class Vertex
  
  attr_accessor :vertex_id
  
  def initialize(vertex_id)
    @vertex_id = vertex_id
    @edges = []
    @children = []
  end
  
  def edges
    @edges
  end
  
  def add_edge(edge)
    unless @edges.include? edge
      @edges.push edge
    end
  end
  
  def add_edges(edges=[])
    @edges = @edges + edges
  end
  
  def add_child(vertex)
    @children.push vertex
  end
  
  def children
    @children
  end
  
  def eql?(another_vertex)
    self.class.equal?(another_vertex.class) && @vertex_id == another_vertex.vertex_id
  end
  
  alias == eql?
  
  def hash
    @vertex_id.hash
  end
  
end

class Edge
  
  attr_accessor :first_vertex, :second_vertex
  
  def initialize(first_vertex, second_vertex)
    @first_vertex = first_vertex
    @second_vertex = second_vertex
  end
  
  def vertices
    return @first_vertex, @second_vertex
  end
  
  def contains_both_vertices?(first_vertex, second_vertex)
    self_vertices = [@first_vertex, @second_vertex]
    self_vertices.include?(first_vertex) && self_vertices.include?(second_vertex)
  end
  
  def eql?(another_edge)
    self.class.equal?(another_edge.class) && self.contains_both_vertices?(another_edge.first_vertex, another_edge.second_vertex)
  end
  
  alias == eql?
  
  def hash
    @first_vertex.hash ^ @second_vertex.hash
  end
  
end

if (ARGV.size > 0)
  init_vertices, init_edges = initialize_input(ARGV[0])
  number_of_runs = init_vertices.size**2
  
  puts "Expected number of runs: #{number_of_runs}"
  
  best_min_cut = -1
  all_min_cuts = []
  
  number_of_runs.times do |current_run_number|  
    
    vertices = Marshal.load(Marshal.dump(init_vertices))
    edges = Marshal.load(Marshal.dump(init_edges))
    
    puts "Running...#{current_run_number}"
    
    ids_for_vertices = 50
    while vertices.size > 2
      
      puts "Vertices size: #{vertices.size}"
      puts "Edges size: #{edges.size}"
      
      random_index = rand(edges.size - 1)
      
      puts "Gettin random edge at #{random_index}..."
      random_edge = edges.delete_at(random_index)
      
      first_vertex, second_vertex = random_edge.vertices
      
      puts "Creating new vertex..."
      composite_vertex = Vertex.new(ids_for_vertices+=1)
      new_edges = first_vertex.edges + second_vertex.edges
      new_edges.uniq!
      
      puts "Detecting and removing self-loop edges..."
      self_loop_edges = new_edges.select { |edge| edge.contains_both_vertices?(first_vertex, second_vertex) }
      new_edges.delete_if { |item| self_loop_edges.include?(item) }
      edges.delete_if { |item| self_loop_edges.include?(item) }
      
      puts "Pointing edges to new composite vertex with id: #{composite_vertex.vertex_id}..."
      edges.collect! do |item|
        if item.first_vertex.eql?(first_vertex) || item.first_vertex.eql?(second_vertex)
          item.first_vertex=composite_vertex
        end          
        if item.second_vertex.eql?(first_vertex) || item.second_vertex.eql?(second_vertex)
          item.second_vertex=composite_vertex
        end
        item
      end
      
      puts "Adding new edges to new vertex, adding child vertices"
      composite_vertex.add_edges(new_edges)
      composite_vertex.add_child(first_vertex)
      composite_vertex.add_child(second_vertex)
      
      puts "Deleting vertices[#{first_vertex.vertex_id}, #{second_vertex.vertex_id}] from input, adding composite vertex..."
      vertices.delete(first_vertex) { puts "Vertex with id #{first_vertex.vertex_id} NOT deleted." }
      vertices.delete(second_vertex) { puts "Vertex with id #{second_vertex.vertex_id} NOT deleted." }
      vertices.push(composite_vertex)
      
      puts ""
      
      vertices.compact!
      edges.compact!

      puts "Vertices size: #{vertices.size}"
      puts "Edges size: #{edges.size}"
      
    end
    
    puts "****************************************"
    puts "Done. Calculating min cut..."
    
    cur_min_cut = edges.size
    puts "Min cut for current run is #{cur_min_cut}"
    all_min_cuts.push cur_min_cut
    
    if best_min_cut == -1 || best_min_cut > cur_min_cut
      best_min_cut = cur_min_cut
    end
    
    puts "-------------------------------------------------------------------------------------------"
    puts "" 
  end
  
  puts "Result best cut is #{best_min_cut}"
    
else
  puts "File name should be specified as the only one argument!"
end
