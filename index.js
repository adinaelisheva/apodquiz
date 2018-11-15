(() => { 
  const verifyAnswer = (e) => {
    const input = e.target;
    const answer = input.parentElement.querySelector('.answer');
    if (input.value.toLowerCase() === answer.innerText.toLowerCase()) {
      const style = input.getAttribute('style');
      input.setAttribute('style',style + 'color:#87d414;font-weight:bold');
      input.setAttribute('disabled','true');
    }
  }

  window.onload = () => {
    document.querySelectorAll('input.blank').forEach((input) => {
      const answerDiv = input.parentElement.querySelector('.answer');
      const answer = answerDiv.innerText.toLowerCase().trim();
      answerDiv.innerHTML = answer;
      const width = Math.max(40, answer.length*10);
      input.setAttribute('style', `width:${width}px;`);
      input.onkeyup = (e) => { verifyAnswer(e); };
    })
    document.querySelector('.quiz').classList.remove('hidden');
  }

})();