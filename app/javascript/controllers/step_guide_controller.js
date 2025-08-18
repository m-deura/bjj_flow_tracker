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
		const step5 = document.querySelector("#step5")

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
					intro: step4.dataset.introText,
					disableInteraction: true
				},
				{
					title: step5.dataset.titleText,
					intro: step5.dataset.introText,
				},
			]
		})

	intro.onAfterChange((el) => {
  	// console.log("今ハイライトしてるのは:", el)
		// console.log(intro.getCurrentStep())

		// 一番上にあるカードを展開し、カード内部(テクニック詳細画面)の説明をする。
		if (intro.getCurrentStep() === 3) {
			const card = document.querySelector(".collapse");
			if (card) card.querySelector("input[type='checkbox']").checked = true;
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

		const intro = introJs.tour().setOptions({
			steps: [
				{
					intro: step0.dataset.introText
				},
				{
					element: "#step1",
					title: step1.dataset.titleText,
					intro: step1.dataset.introText
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText
				},
				{ element: "#step3", title: document.querySelector("#step3Text").dataset.titleText, intro: document.querySelector("#step3Text").dataset.introText },
				{ element: "#step4", title: document.querySelector("#step4Text").dataset.titleText, intro: document.querySelector("#step4Text").dataset.introText },
			]
		})

		intro.onAfterChange(() => {
			if (intro.getCurrentStep() === 2) {
				this.dispatch("openNode");
			}
		});

		// onDrawerReady内部でローカル変数intro使えるようStimulusインスタンスの値に代入
		this.intro = intro;
		this.intro.start();
	}
}
