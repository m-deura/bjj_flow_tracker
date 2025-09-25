TypedDag::Configuration.set edge_class_name: "Edge",
                            node_class_name: "Node",
                            types: { flow: { from: :dag_parents,
                                             to: :dag_children,
                                             all_from: :dag_ancestors,
                                             all_to: :dag_descendants }
                            }
