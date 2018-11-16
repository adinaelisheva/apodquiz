(() => { 
  let score;
  let completed = 0;
  let numQs;

  const input = 'nopqrstuvwxyz0123456789abcdefghijklm';
  const output = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const decode = (str) => {
    var translate = x => input.indexOf(x) > -1 ? output[input.indexOf(x)] : x;
    return str.split('').map(translate).join('');
  }

  const completeQuiz = () => {
    document.querySelector('.finished').classList.remove('invisible');
    const date = new Date();
    date.setTime(date.getTime() + (2*24*60*60*1000)); // Expire in 2 days from now
    const expires = date.toUTCString();
    // value is today's date as a string
    let m = date.getMonth();
    m = m.length < 2 ? `0${m}` : m;
    let d = date.getDate();
    d = d.length < 2 ? `0${d}` : d; 
    const completed = `${m}-${d}-${date.getFullYear()}`;
    document.cookie = `lastcompleted=${completed};expires=${expires};path=/`;
  };

  const verifyAnswer = (e) => {
    const input = e.target;
    const answer = input.parentElement.querySelector('.answer');
    if (input.value.toLowerCase() === decode(answer.innerText.toLowerCase())) {
      const style = input.getAttribute('style');
      input.classList.add('completed');
      input.setAttribute('disabled','true');
      completed++;
      score.querySelector('span.num').innerHTML = completed;
    }
    if (completed >= numQs) {
      completeQuiz();
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