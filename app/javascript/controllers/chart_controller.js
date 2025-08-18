import { Controller } from "@hotwired/stimulus"
import cytoscape from "cytoscape"
import dagre from "cytoscape-dagre"

cytoscape.use(dagre);

// Connects to data-controller="chart"
export default class extends Controller {
	static targets = ["cy", "toggle", "drawer" ]
	static values = {
		fetchUrl: String,
		editUrl: String,
		addUrl: String
	}

	connect() {
		const url = this.fetchUrlValue; // api_v1_chart_path(@chart)
		console.log(this.element.dataset)
		fetch(url)
			.then((response) => response.json())
			.then((elements_data) => {
				this.cy = cytoscape({
				container: this.cyTarget,
				autoungrabify: true,
				elements: elements_data,
				style: [
					{
						selector: "node",
						style: {
							shape: "ellipse",
							width: 1,
							height: 1,
							"background-color": "#FFF",
							label: "data(label)",
							"text-valign": "top",
							"text-halign": "center",
							color: "#333333", // #505050 はやわらかめの黒
							"font-size": "4px",
							padding: "4px",
							"border-width": 0.5,
							"border-color": "#b1b1b6",
							"border-style": "solid",
							"border-cap": "square",
					},
					},
					{
						selector: "edge",
						style: {
							"curve-style": "round-taxi",
							width: 0.5,
							"line-color": "#b1b1b6", // #7570B3 は柔らかい紫
							"target-arrow-shape": "triangle",
							"arrow-scale": 0.2,
							"taxi-radius": 3,
							"taxi-turn": "20px", // 曲がり角の位置として、ソースノードからの絶対距離を指定する（指定しないとソースノードとターゲットノードの相対距離によって位置算出が行われるらしく、同列ノードの曲がり角の位置がズレる）
						},
					},
				],
		layout: {
			name: "dagre",
			rankDir: "LR",
			nodeSep: 10,
			edgeSep: 10,
			ranker: "tight-tree",
					},
				});

				this.cy.on("tap", "node", (evt) => {
					const node = evt.target;
					this.openDrawer(node.data());
				});

				this.cy.on("tap", (evt) => {
					if (evt.target == this.cy) {
						this.closeDrawer()
					}
				});

				this.cy.fit(this.cy.elements(), 50);  // 初期表示
				this.cy.minZoom(this.cy.zoom() * 0.5);  // これ以下にズームアウト不可（迷子防止）
      });
  }

	addNode() {
		this.drawerTarget.src = this.addUrlValue; // new_mypage_chart_node_path(@chart)
		this.toggleTarget.checked = true;
	}

  openDrawer(data) {
		const node_edit_url = this.editUrlValue.replace(":id", data.id);
		// console.log(data.id)
		this.drawerTarget.src = node_edit_url; // edit_mypage_node_path(data.id)
		this.toggleTarget.checked = true;
  }

	closeDrawer() {
		this.toggleTarget.checked = false;
	}

	forStepGuide(){
		console.log("Hello!");
	}
}
