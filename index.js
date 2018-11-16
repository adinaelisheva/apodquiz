(() => { 
  let score;
  let completed = 0;
  let numQs;

  const verifyAnswer = (e) => {
    const input = e.target;
    const answer = input.parentElement.querySelector('.answer');
    if (input.value.toLowerCase() === answer.innerText.toLowerCase()) {
      const style = input.getAttribute('style');
      input.classList.add('completed');
      input.setAttribute('disabled','true');
      completed++;
      score.querySelector('span.num').innerHTML = completed;
    }
    if (completed >= numQs) {
      document.querySelector('.finished').classList.remove('invisible');
    }
  };

  const openAllLinks = () => {
    document.querySelectorAll('a.link.hidden').forEach((link) => {
      window.open(link.getAttribute('href'));
    })
  };

  window.onload = () => {
    const questions = document.querySelectorAll('input.blank');
    numQs = questions.length;
    questions.forEach((input) => {
      const answerDiv = input.parentElement.querySelector('.answer');
      const answer = answerDiv.innerText.toLowerCase().trim();
      answerDiv.innerHTML = answer;
      const width = Math.max(40, answer.length*10);
      input.setAttribute('style', `width:${width}px;`);
      input.onkeyup = (e) => { verifyAnswer(e); };
    });
    document.querySelector('.openlinks').onclick = () => {
      openAllLinks();
    };
    score = document.querySelector('.score');
    score.querySelector('.whole').innerText = questions.length;
    document.querySelector('.quiz').classList.remove('hidden');
  };

})();