import { Controller } from "@hotwired/stimulus";
import { Graph } from '@antv/g6';
import { NodeEvent, EdgeEvent, CanvasEvent } from '@antv/g6';

// Connects to data-controller="chart"
export default class extends Controller {
	static targets = ["cy", "toggle", "drawer" ]
	static values = {
		fetchUrl: String,
		editUrl: String,
		addUrl: String,
		testEnabled: Boolean
	}

  connect() {
    const temp_data = {
      nodes: [
        { id: 'bottom', label: 'bottom' },
				{ id: 'kataeri', label: 'kataeri' },
        { id: 'spider', label: 'spider' },
        { id: 'one-leg', label: 'one-leg' },
        { id: 'waiter', label: 'waiter' },
        { id: 'scissors', label: 'scissors' },
        { id: 'kusakari', label: 'kusakari' },
        { id: 'side', label: 'side' },
				{ id: 'top', label: 'top' },
				{ id: 'leg-drag', label: 'leg-drag' },
				{ id: 'knee', label: 'knee' },
      ],
      edges: [
        { source: 'bottom', target: 'spider' },
				{ source: 'bottom', target: 'kataeri' },
				{ source: 'kataeri', target: 'spider' },
				{ source: 'kataeri', target: 'kusakari' },
        { source: 'spider', target: 'one-leg' },
				{ source: 'spider', target: 'waiter' },
				{ source: 'spider', target: 'scissors' },
        { source: 'one-leg', target: 'side' },
				{ source: 'waiter', target: 'side' },
				{ source: 'scissors', target: 'side' },
				{ source: 'kusakari', target: 'side' },
				{ source: 'side', target: 'bottom' },
				{ source: 'top', target: 'leg-drag' },
				{ source: 'top', target: 'knee' },
				{ source: 'knee', target: 'side' },
				{ source: 'leg-drag', target: 'side' },
      ]
    }

		const CAT_FILL = {
  		submission: '#F28B82',
  		sweep:      '#81D4FA',
  		pass:       '#A5D6A7',
  		guard:      '#90A4AE',
  		control:    '#CE93D8',
  		takedown:   '#FFB74D',
		};
		const DEFAULT_FILL = '#FFFFFF'; //'#eef2ff'?

		const url = this.fetchUrlValue; // api_v1_chart_path(@chart)
		console.log(this.element.dataset)
		fetch(url)
			.then((response) => response.json())
			.then((data) => {

    		this.graph = new Graph({
		      container: this.cyTarget,
					autoFit: 'view',
					data: data,
					zoomRange: [0.1, 10],
					behaviors: [
						'zoom-canvas',  // PC用ズーム機能
						'click-select',
						'focus-element',
						function () {  // モバイル用ズーム機能
							return {
								type: 'zoom-canvas',
								trigger: ['pinch'],
								sensitivity: 0.8, // Lower sensitivity for smoother zoom changes
								};
						},
						{
							type: 'drag-canvas',
							range: 3,
						},
					],
					plugins: [
		  			// {
		    		// 	type: 'grid-line',
		    		// 	key: 'my-grid-line', // Specify a unique 		identifier for dynamic updates
		    		// 	size: 20,
		    		// 	stroke: '#0001',
		    		// 	follow: true,
		  			// },
						{
		    			type: 'tooltip',
		    			enable: (e, items) => e.targetType === 'edge' && items[0].data.trigger, 
		    			getContent: (e, items) => {
		    			  return `<div>${items[0].data.trigger}</div>`;
		    			},
						},
						// {
		      	// 	type: 'toolbar',
		      	// 	getItems: () => [
		        // 		{ id: 'zoom-in', value: 'zoom-in' },
				    //     { id: 'zoom-out', value: 'zoom-out' },
				    //     { id: 'auto-fit', value: 'auto-fit' },
				    //   ],
				    //   onClick: (value) => {
				    //     // Handle button click events
				    //     if (value === 'zoom-in') {
				    //       graph.zoomTo(1.1);
				    //     } else if (value === 'zoom-out') {
				    //       graph.zoomTo(0.9);
				    //     } else if (value === 'auto-fit') {
				    //       graph.fitView();
				    //     }
		      	// 	},
		    		// },
					],
		      layout: { 
						type: 'antv-dagre', 
						rankdir: 'LR', 
						nodesep: 10,
						ranksep: 80,
					},
		      node: {
		        type: 'circle',
		        style: {
							radius: 6, 
							lineWidth: 1, 
							stroke: '#94a3b8',
							fill: (d) => CAT_FILL[d.data.category] ?? DEFAULT_FILL,
							labelText: (d) => `${d.data.label}`,
		      		labelFill: '#333333',
		      		// labelFontSize: 12,
		      		labelPlacement: 'top',
		      		labelWordWrap: true,
		      		labelMaxWidth: '500%',  
						},
		      },
		      edge: {
		        type: 'polyline',
		        style: { 
							stroke: '#94a3b8',
							lineWidth: 1.5, 
							endArrow: true,
							endArrowType: 'vee',
							endArrowSize: 7,
							startDirections: 'right',
							radius: 6,
							// router: { 
							// 	type: 'orth',
							// 	padding: 20,
							// }
						}
		      },
		    })
			
				this.graph.render();

				this.graph.on(NodeEvent.CLICK, (evt) => {
					const { target } = evt; // Get the ID of the clicked node
  				// console.log(`Node ${target.id} was clicked`);
					this.openDrawer(target.id);
				});

				// RSpecテストのノードクリック操作に利用
				if (this.testEnabledValue) {
					this._onTestClickNode = (e) => {
						// 取得したノードをタップする
						// e は CustomEvent で { detail: { id: ... } }
						const id = String(e.detail.id)
						if (!id || !this.graph) return

						// 取得したノードをタップする
						this.graph.emit(NodeEvent.CLICK, { target: { id } });
						};
					// RSpec内で発生させた「test:click-node」イベントを拾ったら、「_onTestClickNode」を実行
					window.addEventListener('test:click-node', this._onTestClickNode)
				}
			});
		}

	addNode() {
		this.drawerTarget.src = this.addUrlValue; // new_mypage_chart_node_path(@chart)
		this.toggleTarget.checked = true;
	}

	openDrawer(data) {
		// this.drawerTarget.src = node_edit_url; // edit_mypage_node_path(data.id)
		this.toggleTarget.checked = true;

		const drawer = this.drawerTarget
		const node_edit_url = this.editUrlValue.replace(":id", data.id);
		console.log(data.id)
		const node_edit_url = this.editUrlValue.replace(":id", data);
		console.log(`${data} in openDrawer function`)
		drawer.src = node_edit_url  // edit_mypage_node_path(data.id)
		// console.log(this.graph)
  }

	closeDrawer() {
		this.toggleTarget.checked = false;
	}

	forStepGuide(){
		// 任意ノード(最初のノード)を取得
		const nodes = this.graph.getNodeData()
		const firstNode = nodes[0];

		if (firstNode) {
			// console.log(firstNode.data());
			this.openDrawer(firstNode.id);
		}
	}

	disconnect() {
  if (this._onTestClickNode) {
    window.removeEventListener('test:click-node', this._onTestClickNode);
    this._onTestClickNode = null;
  }
	}
}
