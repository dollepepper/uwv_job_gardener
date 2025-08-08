let indicator = document.getElementById('indicator');
let successZone = document.getElementById('success-zone');
let resultDiv = document.getElementById('result');
let bar = document.getElementById('bar');

let running = false;
let indicatorPos = 0;
let direction = 1;
let interval = null;

function startMinigame() {
	running = true;
	indicatorPos = 0;
	direction = 1;
	resultDiv.textContent = '';
	indicator.style.left = '0px';

	setRandomSuccessZone();

	interval = setInterval(moveIndicator, 16);
}

function setRandomSuccessZone() {
	let barWidth = bar.offsetWidth;
	let zoneWidth = successZone.offsetWidth;

	let randomLeft = Math.floor(Math.random() * (barWidth - zoneWidth));
	successZone.style.left = randomLeft + 'px';
}

function moveIndicator() {
	if (!running) return;
	let barWidth = bar.offsetWidth;
	let indWidth = indicator.offsetWidth;
	indicatorPos += direction * 4;
	if (indicatorPos <= 0) {
		indicatorPos = 0;
		direction = 1;
	} else if (indicatorPos >= barWidth - indWidth) {
		indicatorPos = barWidth - indWidth;
		direction = -1;
	}
	indicator.style.left = indicatorPos + 'px';
}

function checkSuccess() {
	let barWidth = bar.offsetWidth;
	let indWidth = indicator.offsetWidth;
	let zoneLeft = successZone.offsetLeft;
	let zoneRight = zoneLeft + successZone.offsetWidth;
	let indCenter = indicatorPos + indWidth / 2;
	if (indCenter >= zoneLeft && indCenter <= zoneRight) {
		return true;
	}
	return false;
}

window.addEventListener('message', function (event) {
	if (event.data && event.data.action === 'show') {
		document.getElementById('minigame-container').style.display = 'block';
		startMinigame();
	} else if (event.data && event.data.action === 'hide') {
		document.getElementById('minigame-container').style.display = 'none';
		running = false;
		clearInterval(interval);
	}
});

document.addEventListener('keydown', function (e) {
	if (!running) return;
	if (e.code === 'KeyE') {
		if (checkSuccess()) {
			resultDiv.textContent = 'Success!';
			running = false;
			clearInterval(interval);
			setTimeout(() => {
				document.getElementById('minigame-container').style.display = 'none';
				fetch('https://UWV_job/weedrakeResult', {
					method: 'POST',
					body: JSON.stringify({ success: true }),
				});
			}, 600);
		} else {
			resultDiv.textContent = 'Miss! Try again.';
		}
	}
});
