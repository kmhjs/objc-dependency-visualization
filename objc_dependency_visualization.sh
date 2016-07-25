#! /usr/bin/env zsh

#
# Initialize file paths
#
temp_relation_file_path=/tmp/temp_graph_relation.dot
temp_result_file_path=/tmp/temp_result_graph.dot
output_file_name=graph_${$(pwd):t:r}

#
# Initialize temporary file
#
: > ${temp_relation_file_path}

#
# Write out dependencies to temporary file
#

# Select target files
# If you want to exclude implementation (.m) file, switch to '.h' and '.hh' file check line.
find . -iname '*.h' -or -iname '*.m' -or -iname '*.hh' -or -iname '*.mm' | \
#find . -iname '*.h' -or -iname '*.hh' | \

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
  egrep -v '^(Foundation\.h|Cocoa\.h|UIKit\.h)' | \

  # Remove arrow to self
  egrep -v "($(echo ${filename:t:r} | sed 's/\+/\\\+/').h|$(echo ${filename:t:r} | sed 's/\+/\\\+/'))" | \

  while read dest_filename; do;
    # Write out to temporary file
    echo "\"${filename:t:r}\" -> \"${dest_filename:t:r}\";" >> ${temp_relation_file_path}
  ; done
; done

#
# Write out .dot file
#
: > ${temp_result_file_path}

if [[ ! -f ${temp_relation_file_path} ]]; then
  echo 'Error: Could not find temporary file.' 1>&2
  return 1
fi

cat <<EOF > ${temp_result_file_path}
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

#
# Output graph file sorted by target file (or class) name.
#

# If you want to change sorting rule (sort key), switch following line.
# Default sorting key is import (or include) target file name. : `sort -k3`
cat ${temp_relation_file_path} | sort | uniq | sort -k3 >> ${temp_result_file_path}
#cat ${temp_relation_file_path} | sort | uniq | sort -k1 >> ${temp_result_file_path}

echo '}' >> ${temp_result_file_path}

#
# Rendering
#
if [[ ! -f ${temp_result_file_path} ]]; then
  echo 'Error: Could not find output file.' 1>&2
  return 1
fi
cp ${temp_result_file_path} ./${output_file_name}.dot

if [[ -x $(which dot) ]]; then
  # If no "dot" command found, just clean up temporary file, and keep result dot file.
  dot -Tpdf ${temp_result_file_path} -o ${output_file_name}.pdf
else
  echo 'Could not find "dot" command. Extract only .dot file.' 1>&2
fi

#
# Clean up
#
if [[ -f ${temp_relation_file_path} ]]; then
  rm -f ${temp_relation_file_path}
fi

if [[ -f ${temp_result_file_path} ]]; then
  rm -f ${temp_result_file_path}
fi
