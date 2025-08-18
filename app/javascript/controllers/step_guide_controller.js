import { Controller } from "@hotwired/stimulus"
import introJs from "intro.js"

// Connects to data-controller="step-guide"
export default class extends Controller {
  connect() {
		// introJs.tour().setOption("dontShowAgain", true).start();
  }

	startMenuGuide() {
		const step0 = document.querySelector("#step0")
		const step1 = document.querySelector("#step1") 
		const step2 = document.querySelector("#step2") 
		const step3 = document.querySelector("#step3")
		const step4 = document.querySelector("#step4")

		introJs.tour().setOptions({
			steps: [
				{
					title: step0.dataset.titleText,
					intro: step0.dataset.introText
				},
				{
					element: step1,
					title: step1.dataset.titleText,
					intro: step1.dataset.introText
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText
				},
				{
					element: step3,
					title: step3.dataset.titleText,
					intro: step3.dataset.introText
				},
				{  
					intro: step4.dataset.introText
				},
			]
		}).start();
	}

	startTechniqueGuide() {
		const step0 = document.querySelector("#step0")
		const step1 = document.querySelector("#step1")
		const step2 = document.querySelector("#step2")
		const step3 = document.querySelector("#step3")
		const step4 = document.querySelector("#step4")

		const intro = introJs.tour().setOptions({
			steps: [
				{
					intro: step0.dataset.introText
				},
				{
					element: step1,
					title: step1.dataset.titleText,
					intro: step1.dataset.introText
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText
				},
				{
					title: step3.dataset.titleText,
					intro: step3.dataset.introText
				},
				{
					element: document.querySelector(".collapse"),
					title: step4.dataset.titleText,
					intro: step4.dataset.introText
				},
			]
		})

	intro.onAfterChange((el) => {
  	// console.log("今ハイライトしてるのは:", el)
		// console.log(intro.getCurrentStep())

		/* テクニック詳細画面ガイドの直前にカードを開こうと努めた際の名残。
		function waitUntilVisible(card, { timeout = 500, interval = 50 } = {}){
				return new Promise((resolve) => {
					const start = performance.now();

					(function check(){
						const content = card.querySelector(".collapse-content");
						if (content && content.offsetHeight > 0){
							return resolve();	
						}
						if (performance.now() - start > timeout){
							return resolve();
						}
						setTimeout(check, interval);
					})();
				});
			}
			*/

		// 一番上にあるカードを展開し、カード内部(テクニック詳細画面)の説明をする。
		if (intro.getCurrentStep() === 3) {
			const card = document.querySelector(".collapse");
			if (card) card.querySelector("input[type='checkbox']").checked = true;

			// await waitUntilVisible(card);
			}
	})

		intro.start();
		// console.log(intro)
	}

	startChartGuide() {
		const step0 = document.querySelector("#step0")
		const step1 = document.querySelector("#step1")
		const step2 = document.querySelector("#step2")
		const step3Text = document.querySelector("#step3Text")
		const step4Text = document.querySelector("#step4Text")

		const baseSteps = [
				{
					intro: step0.dataset.introText
				},
				{
					element: step1,
					title: step1.dataset.titleText,
					intro: step1.dataset.introText
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText
				},
		]

		this._baseSteps = baseSteps;
	 	this._step3Meta = { title: step3Text.dataset.titleText, intro: step3Text.dataset.introText };
	 	this._step4Meta = { title: step4Text.dataset.titleText, intro: step4Text.dataset.introText };


		const intro = introJs.tour().setOptions({ steps: baseSteps });

		intro.onAfterChange(() => {
			if (intro.getCurrentStep() === 2) {
				console.log("[guide] dispatch openNode");
				this.dispatch("openNode");
			}
		});

		// onDrawerReady内部でローカル変数intro使えるようStimulusインスタンスの値に代入
		this.intro = intro;
		intro.start();
	}
		 
	onDrawerReady() {
		console.log("[guide] onDrawerReady called!!");

		// ドロワー展開後、DOM要素の位置を再計算させるつもりで refresh() を使ったが機能せず。
		// this.intro?.refresh();
		if (this._stepsAdded) return;
		
		const currentIndex0 = this.intro.getCurrentStep(); // 0-based
  	this.intro.exit(); // いったん終了

		const newSteps = [
			...this._baseSteps,
			{ element: "#step3", title: document.querySelector("#step3Text").dataset.titleText, intro: document.querySelector("#step3Text").dataset.introText },
			{ element: "#step4", title: document.querySelector("#step4Text").dataset.titleText, intro: document.querySelector("#step4Text").dataset.introText },
		];
		const intro = introJs.tour().setOptions({ steps: newSteps });
		this.intro = intro;
		console.log(intro);
		intro.start();
		intro.goToStep(2);
	}
}
