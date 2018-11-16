(() => { 
  let score;
  let completed = 0;
  let numQs;

  const decode = (str) => {
    const input = 'nopqrstuvwxyz0123456789abcdefghijklm';
    const output = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var translate = x => input.indexOf(x) > -1 ? output[input.indexOf(x)] : x;
    return str.split('').map(translate).join('');
  };
  
  const getMiniDateStr = (date) => {
    let m = date.getMonth() + 1;
    m = m.length < 2 ? `0${m}` : m;
    let d = date.getDate();
    d = d.length < 2 ? `0${d}` : d; 
    return `${m}-${d}-${date.getFullYear()}`;
  };

  const cookiename = 'lastcompleted';

  const completeQuiz = () => {
    document.querySelector('.finished').classList.remove('invisible');
    const date = new Date();

    // value is today's date as a string
    const completed = getMiniDateStr(date);
    
    date.setTime(date.getTime() + (2*24*60*60*1000)); // Expire in 2 days from now
    const expires = date.toUTCString();
    
    document.cookie = `${cookiename}=${completed};expires=${expires};path=/`;
  };

  const hasQuizAlreadyBeenCompleted = () => {
    const cookies = document.cookie.split('; ');
    for (let i = 0; i < cookies.length; i++) {
      const parts = cookies[i].split('=');
      if (parts[0] !== cookiename) {  
        continue;
      }
      const lastDate = parts[1];
      const today = new Date();
      return lastDate === getMiniDateStr(today);
    }
    // If we got here there's no lastcompleted cookie
    return false;
  }

  completeQuestion = (input) => {
    input.classList.add('completed');
    input.setAttribute('disabled','true');
    completed++;
    score.querySelector('span.num').innerHTML = completed;
    if (completed >= numQs) {
      completeQuiz();
    }
  }

  const verifyAnswer = (e) => {
    const input = e.target;
    const answer = input.parentElement.querySelector('.answer');
    if (input.value.toLowerCase() === decode(answer.innerText.toLowerCase())) {
      completeQuestion(input);
    }
  };

  const openAllLinks = () => {
    document.querySelectorAll('a.link.hidden').forEach((link) => {
      window.open(link.getAttribute('href'));
    })
  };

  window.onload = () => {
    const quizAlreadyCompleted = hasQuizAlreadyBeenCompleted();

    const questions = document.querySelectorAll('input.blank');
    numQs = questions.length;
    
    score = document.querySelector('.score');
    score.querySelector('.whole').innerText = numQs;
    
    questions.forEach((input) => {
      const answerDiv = input.parentElement.querySelector('.answer');
      const answer = answerDiv.innerText.toLowerCase().trim();
      answerDiv.innerHTML = answer;
      
      const width = Math.max(40, answer.length*10);
      input.setAttribute('style', `width:${width}px;`);

      if (quizAlreadyCompleted) {
        input.value = decode(answer);
        completeQuestion(input);
      } else {
        // No point in setting a listener if the input is already completed
        input.onkeyup = (e) => { verifyAnswer(e); };
      }
    });

    document.querySelector('.openlinks').onclick = () => {
      openAllLinks();
    };

    document.querySelector('.quiz').classList.remove('hidden');
  };

})();