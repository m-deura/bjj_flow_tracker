import { Controller } from "@hotwired/stimulus"
import introJs from "intro.js"

// Connects to data-controller="step-guide"
export default class extends Controller {
	static targets = ["step0", "step1", "step2", "step3", "step4"]
  connect() {
		// introJs.tour().setOption("dontShowAgain", true).start();
  }

	startMenuGuide() {
		const step0 = this.step0Target
		const step1 = this.step1Target
		const step2 = this.step2Target
		const step3 = this.step3Target
		const step4 = this.step4Target

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
		console.log("Hello!")
		const step0 = this.step0Target
		const step1 = this.step1Target
		const step2 = this.step2Target
		const step3 = this.step3Target
		const step4 = this.step4Target

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


	startChartGuide() {
		const step0 = this.step0Target
		const step1 = this.step1Target
		const step2 = this.step2Target
		const step3 = this.step3Target
		const step4 = this.step4Target

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
}
