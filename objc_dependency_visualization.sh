#! /usr/bin/env zsh

# Initialize temporary file
: > ./temp_graph_relation.dot

# Select target files
find . -iname '*.h' -or -iname '*.m' -or -iname '*.hh' -or -iname '*.mm' | \

# If you want to enable test files, disable following one line.
# May be you need to add some rules to regular expression.
egrep -v '(.*Tests\..*$|XCTest\.h)' | \

while read filename; do;
  cat ${filename} | \

  # Remove leading spaces
  sed 's/^  *//' | \

  # Pick up import or include lines, and remove words
  egrep '^(#import|#include)' | sed 's/#import//g;s/#include//g' | \

  # Remove unnecessary symbols
  tr -d '<> "' | \

  # Pick up file name only
  tr '/' ' ' | rev | cut -d ' ' -f 1 | rev | \

  # Remove duplicates
  sort | uniq | \

  # Apply exceptions
  egrep -v '(Foundation\.h|Cocoa\.h|UIKit\.h)' | \

  # Remove arrow to self
  egrep -v "($(echo ${filename:t:r} | sed 's/\+/\\\+/').h|$(echo ${filename:t:r} | sed 's/\+/\\\+/'))" | \

  while read dest_filename; do;
    # Write out to temporary file
    echo "\"${filename:t:r}\" -> \"${dest_filename:t:r}\";" >> temp_graph_relation.dot
  ; done
; done

# Write out dot file
: > ./temp_result_graph.dot

if [[ ! -f ./temp_graph_relation.dot ]]; then
  echo 'Error: Could not find temporary file.' 1>&2
  return 1
fi
cat <<EOF > ./temp_result_graph.dot
digraph dependencies {
  graph [
    charset = "UTF-8",
    layout = dot,
    style = filled,
    overlap = false,
    rankdir = LR
  ];
  node [
    colorscheme = greys9,
    style = "solid,filled",
    fontcolor = 8,
    fillcolor = 1,
    color = 6
  ];
  edge [
    colorscheme = greys9,
    color = 6
  ];
EOF

# Output graph file sorted by target file (or class) name.
cat temp_graph_relation.dot | sort | uniq | sort -k3 >> ./temp_result_graph.dot
echo '}' >> ./temp_result_graph.dot

# Rendering
if [[ ! -f ./temp_result_graph.dot ]]; then
  echo 'Error: Could not find output file.' 1>&2
  return 1
fi
cp ./temp_result_graph.dot ./graph_${$(pwd):t:r}.dot

if [[ -x $(which dot) ]]; then
  # If no "dot" command found, just clean up temporary file, and keep result dot file.
  dot -Tpdf temp_result_graph.dot -o graph_${$(pwd):t:r}.pdf
else
  echo 'Error: Could not find "dot" command.' 1>&2
fi

# Clean up
if [[ -f ./temp_graph_relation.dot ]]; then
  rm -f ./temp_graph_relation.dot
fi

if [[ -f ./temp_result_graph.dot ]]; then
  rm -f ./temp_result_graph.dot
fi
