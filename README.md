objc-dependency-visualization
===

This project is for visualization of dependencies ( `import` / `include` ) between codes.

## Dependencies

* zsh (tested with `5.2` )
* Graphviz (If you want to render graph.)

## Usage

1. Put `objc_dependency_visualization.sh` to your target directory.
2. Run as `./objc_dependency_visualization.sh` .
3. `graph_{directory name}.dot` will be generated at the same directory to `objc_dependency_visualization.sh` .
4. If you have Graphviz ( `dot` command), `graph_{directory name}.pdf` will be generated too.

## Note

* This script only checks `import` or `include` relations.

## License

See `LICENSE` .
