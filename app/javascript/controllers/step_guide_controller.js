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
		// Settingsメニュー用
		// const step3 = document.querySelector("#step3")
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
				// Settingsメニュー用
				/*
				{
					element: step3,
					title: step3.dataset.titleText,
					intro: step3.dataset.introText
				},
				*/
				{  
					intro: step4.dataset.introText
				},
			], showBullets: false, showProgress: true
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
					element: document.querySelector(".drawer-side"),
					title: step4.dataset.titleText,
					intro: step4.dataset.introText,
					// ハイライトが当たった展開済みカードが閉じられないようにする
					disableInteraction: true
				},
				{
					title: step5.dataset.titleText,
					intro: step5.dataset.introText,
				},
			], 
			showBullets: false, // カード展開がある都合上、ガイドステップのスキップ要制御
			showProgress: true // Bulletsの代替となるガイド進行状況確認用UI
		})

	intro.onAfterChange((el) => {
  	// console.log("今ハイライトしてるのは:", el)
		// console.log(intro.getCurrentStep())

		// 一番上にあるカードを展開し、カード内部(テクニック詳細画面)の説明をする。
		if (intro.getCurrentStep() === 3) {
			const firstCard = document.querySelector("a[data-turbo-frame='technique-drawer']");
			if (firstCard) firstCard.click();
			}
	})
		intro.start();
		// console.log(intro)
	}

	startChartGuide() {
		const step0 = document.querySelector("#step0")
		const step1 = document.querySelector("#step1")
		const step2 = document.querySelector("#step2")
		const step3 = document.querySelector("#step3")

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
				{ element: step3,
					title: step3.dataset.titleText,
					intro: step3.dataset.introText,
					disableInteraction: true
				},
			], 
			showBullets: false, 
			showProgress: true
		})

		intro.onAfterChange(() => {
			// step2の時、chart_controllerに頼んでドロワーを開く。
			if (intro.getCurrentStep() === 2) {
				this.dispatch("openNode");
			}
		});

		intro.start();
	}

	startNodeGuide(){
		const step0 = document.querySelector("#step0n")
		const step1 = document.querySelector("#step1n")
		const step2 = document.querySelector("#step2n")
		const step3 = document.querySelector("#step3n")
		const step4 = document.querySelector("#step4n")

		const intro = introJs.tour().setOptions({
			steps: [
				{
					intro: step0.dataset.introText,
					disableInteraction: true
				},
				{
					element: step1,
					title: step1.dataset.titleText,
					intro: step1.dataset.introText,
					disableInteraction: true
				},
				{
					element: step2,
					title: step2.dataset.titleText,
					intro: step2.dataset.introText,
					disableInteraction: true
				},
				{ 
					element: step3,
					title: step3.dataset.titleText,
					intro: step3.dataset.introText,
					disableInteraction: true
				},
				{
					title: step4.dataset.titleText,
					intro: step4.dataset.introText,
					disableInteraction: true
				},
			], 
			showBullets: false, 
			showProgress: true
		})

		intro.onBeforeChange(() => {
			intro.refresh();
			// 小さい画面だと最終ステップガイドが見切れるため、画面上部へ自動スクロール。
			if (intro.getCurrentStep() === 4) {
				window.scrollTo({ top: 0, behavior: "smooth" })
			}
		});

		intro.start();
	}
}
