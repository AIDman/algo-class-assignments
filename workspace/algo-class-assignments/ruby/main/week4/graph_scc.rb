# The file contains the edges of a directed graph. Vertices are labeled as positive integers from 1 to 875714. 
# Every row indicates an edge, the vertex label in first column is the tail and the vertex label in second column is the head 
# (recall the graph is directed, and the edges are directed from the first column vertex to the second column vertex). 
# So for example, the 11th row looks likes : "2 47646". This just means that the vertex with label 2 has an outgoing edge to the vertex with label 47646
#
# Your task is to code up the algorithm from the video lectures for computing strongly connected components (SCCs), and to run this algorithm on the given graph.
#
# Output Format: You should output the sizes of the 5 largest SCCs in the given graph, in decreasing order of sizes, separated by commas (avoid any spaces). 
# So if your algorithm computes the sizes of the five largest SCCs to be 500, 400, 300, 200 and 100, then your answer should be "500,400,300,200,100". 
# If your algorithm finds less than 5 SCCs, then write 0 for the remaining terms. Thus, if your algorithm computes only 3 SCCs whose sizes are 400, 300, and 100, 
# then your answer should be "400,300,100,0,0".


require 'zip/zip'

# Global variable for finish times, just to keep it simple
$finish_time = 0

def initialize_input(filename)
  extracted_filename = filename+".txt"
  
  File.delete extracted_filename if File.exist? extracted_filename

  # assume we have only one file in the archive
  Zip::ZipFile.open(filename) do |zip_file|
    zip_file.each do |zip_entry|
      if zip_entry.file?
        puts "Extracting input data..."
        zip_entry.extract(extracted_filename)
      end
    end
  end
  puts "Data extracted."
  
  puts "Reading extracted file into memory..."
  input_data = File.readlines(extracted_filename)
  puts "Done."
  
  puts "Reading from input file..."
  input_vertices = {}
  overall_lines_number = input_data.size
  input_data.each_with_index do |line, line_number|
    
    if line_number % 10000 == 0
      puts "line number #{line_number} of #{overall_lines_number}..."
    end
    
    row = line.split(" ")
    raise "Error while reading input! line #{line_number} contains #{row.size} components instead of 2!" unless row.size == 2
    
    start_vertex_id, end_vertex_id = row[0].to_i, row[1].to_i
    start_vertex = input_vertices[start_vertex_id]
    end_vertex = input_vertices[end_vertex_id]
    unless start_vertex
      start_vertex = Vertex.new(start_vertex_id)
      input_vertices[start_vertex_id] = start_vertex
    end
    unless end_vertex
      end_vertex = Vertex.new(end_vertex_id)
      input_vertices[end_vertex_id] = end_vertex
    end
    
    edge = Edge.new(start_vertex, end_vertex)
    start_vertex.add_outgoing_edge edge
    end_vertex.add_incoming_edge edge
  end

  File.delete extracted_filename if File.exist? extracted_filename
  
  puts "Sorting returning result..."
  return input_vertices.values.sort_by { |vertex| vertex.vertex_id}
end

class Vertex
  
  attr_accessor :vertex_id, :explored, :finish_time, :incoming_edges, :outgoing_edges
  
  def initialize(vertex_id)
    @vertex_id = vertex_id
    @incoming_edges = []
    @outgoing_edges = []
    @explored = false
    @finish_time = -1
  end
  
  def add_incoming_edge(edge)
    unless @incoming_edges.include? edge
      @incoming_edges.push edge
    end
  end

  def add_outgoing_edge(edge)
    unless @outgoing_edges.include? edge
      @outgoing_edges.push edge
    end
  end
  
  def explored?
    @explored
  end
  
  # Depth-First search - NOT used because of "stack level too deep" error
  def search(reversed_graph=false)
    @explored=true
    edges = []
    if reversed_graph
      edges = @incoming_edges
    else
      edges = @outgoing_edges
    end
    explored_nodes_number = 1;
    edges.each do |edge|
      end_vertex = edge.end_vertex
      if reversed_graph
        end_vertex = edge.start_vertex
      end
      unless end_vertex.explored?
        explored_nodes_number += end_vertex.search(reversed_graph)
      end
    end
    if reversed_graph
      $finish_time += 1
      @finish_time = $finish_time
    end
    explored_nodes_number
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
  
  attr_accessor :start_vertex, :end_vertex
  
  def initialize(start_vertex, end_vertex)
    @start_vertex = start_vertex
    @end_vertex = end_vertex
  end
  
  def eql?(another_edge)
    self.class.equal?(another_edge.class) && self.start_vertex.eql?(another_edge.start_vertex) && self.end_vertex.eql?(another_edge.end_vertex)
  end
  
  alias == eql?
  
  def hash
    @start_vertex.hash ^ @end_vertex.hash
  end
  
end

if (ARGV.size > 0)
  init_vertices = initialize_input(ARGV[0])
  puts "Number of vertices in graph: #{init_vertices.size}"
  
  puts "Running DFS-Loop on reversed graph to assign finish times to nodes..."
  init_vertices.reverse_each do |v|
    unless v.explored?
      # see also Vertex::search(), 
      # had to implement Depth-First search this way cause recursive calls make Ruby fail with "stack level too deep" error
      vertex_stack = [v]
      while !vertex_stack.empty?
        vertex = vertex_stack.last
        vertex.explored = true
        pushed_new_vertex_to_stack = false
        vertex.incoming_edges.each do |edge|
          unless edge.start_vertex.explored?
            vertex_stack.push edge.start_vertex
            pushed_new_vertex_to_stack = true
            break
          end
        end
        if pushed_new_vertex_to_stack
          next
        end
        vertex_stack.pop
        $finish_time += 1
        vertex.finish_time = $finish_time
        if $finish_time % 10 == 0
          puts "Current finish time is #{$finish_time}"
        end
      end
    end
  end
  
  # We could maintain separate queue which could collect graph nodes when they are assigned a finish time
  # to avoid additional sorting here which of course increases the running time of the algorithm.
  # But we'll keep this code just for simplicity having in mind that it's possible to get rid of it when necessary.
  puts "Sorting vertices by finish time..."
  init_vertices.sort_by! { |vertex| vertex.finish_time }
  
  # mark all vertices unexplored again
  init_vertices.each do |vertex|
    vertex.explored = false
  end
  
  puts "Running DFS-Loop on direct graph and counting SCCs sizes..."
  scc_sizes = []
  init_vertices.reverse_each do |v|
    unless v.explored?
      vertex_stack = [v]
      scc_size = 0
      while !vertex_stack.empty?
        vertex = vertex_stack.last
        vertex.explored = true
        pushed_new_vertex_to_stack = false
        vertex.outgoing_edges.each do |edge|
          unless edge.end_vertex.explored?
            vertex_stack.push edge.end_vertex
            pushed_new_vertex_to_stack = true
            break
          end
        end
        if pushed_new_vertex_to_stack
          next
        end
        vertex_stack.pop
        scc_size += 1
      end
      scc_sizes.push scc_size
    end
  end
  
  while scc_sizes.size < 5
    scc_sizes.push 0
  end
  scc_sizes.sort!
  sizes = scc_sizes.reverse.take(5)
  
  puts "Got these sizes of 5 biggest SCCs: #{sizes.join(',')}"
  
else
  puts "File name of a ZIP archive should be specified as the only one argument!"
end
