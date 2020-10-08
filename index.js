(() => { 
  let score;
  let completed = 0;
  let numQs;
  const curQCookieName = 'curq';
  let isMobile;

  function decode(str) {
    const input = 'nopqrstuvwxyz0123456789abcdefghijklm';
    const output = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var translate = x => input.indexOf(x) > -1 ? output[input.indexOf(x)] : x;
    return str.split('').map(translate).join('');
  }

  function updateCurQCookie(value) {
    const d = new Date();
    // Expire tomorrow at 1am
    d.setDate(d.getDate() + 1);
    d.setHours(1,0,0,0);
    document.cookie=`${curQCookieName}=${value};expires=${d.toGMTString()}`;
  }

  function getCurrentQuestion() {
    const cookies = document.cookie.split('; ');
    for (let i = 0; i < cookies.length; i++) {
      const parts = cookies[i].split('=');
      if (parts[0] === curQCookieName) {  
        return parseInt(parts[1]);
      }
    }
    return 0;
  }

  function completeQuestion(input) {
    input.classList.add('completed');
    input.setAttribute('disabled','true');
    completed++;
    score.querySelector('span.num').innerHTML = completed;

    updateCurQCookie(completed);
    
    if (completed >= numQs) {
      completeQuiz();
    } else {
      const questions = document.querySelectorAll('.questionContainer');
      questions[completed - 1].classList.add('hidden');
      questions[completed].classList.remove('hidden');
    }
  }

  function completeQuiz() {
    const finished = document.querySelector('.finished');
    finished.classList.remove('invisible');

    document.querySelectorAll('.questionContainer').forEach((q) => {
      !isMobile && q.classList.remove('hidden');
      q.querySelector('.readPrompt').classList.add('hidden');
    });

    if (isMobile) {
      document.querySelectorAll('button.mobile').forEach((b) => {
        b.classList.remove('hidden');
      });
    }

  }

  function verifyAnswer(e) {
    const input = e.target;
    const answer = input.parentElement.querySelector('.answer');
    if (input.value.toLowerCase() === decode(answer.innerText.toLowerCase())) {
      completeQuestion(input);
    }
  }

  function openAllLinks() {
    document.querySelectorAll('a.link.hidden').forEach((link) => {
      window.open(link.getAttribute('href'));
    })
  }

  function switchMobileQuestion(el) {
    const direction = el.innerText === '<' ? -1 : 1;
    const questions = document.querySelectorAll('.questionContainer');
    let i = 0;
    for (; i < questions.length; i++) {
      if (!questions[i].classList.contains('hidden')) {
        break;
      }
    }
    questions[i].classList.add('hidden');
    i = (i + direction) % questions.length;
    if (i < 0) { i += questions.length; }
    questions[i].classList.remove('hidden');
  }

  function hideText() {
    [
      document.querySelector('.header'),
      document.querySelector('.explanation'),
      document.querySelector('.quiz'),
    ].forEach((el) => {
      el.classList.add('invisible');
    });
  }

  function showText() {
    [
      document.querySelector('.header'),
      document.querySelector('.explanation'),
      document.querySelector('.quiz'),
    ].forEach((el) => {
      el.classList.remove('invisible');
    });
  }

  function toggleTextVisibility(el) {
    const command = el.innerText.split(' ')[0];
    if (command === 'Hide') {
      el.innerText = 'Show Text';
      hideText();
    } else {
      el.innerText = 'Hide Text';
      showText();
    }
  }

  window.onload = () => {
    isMobile = document.body.clientWidth < 600;

    const questions = document.querySelectorAll('.questionContainer');
    numQs = questions.length;
    
    score = document.querySelector('.score');
    score.querySelector('.whole').innerText = numQs;

    const curQ = getCurrentQuestion();
    const quizAlreadyCompleted = curQ >= numQs;
    
    if (!quizAlreadyCompleted) {
      questions[curQ].classList.remove('hidden');
    }
        
    for (let i = 0; i < numQs; i++) {
      const question = questions[i];
      const input = question.querySelector('input');
      const answerDiv = question.querySelector('.answer');
      const answer = answerDiv.innerText.toLowerCase().trim();
      answerDiv.innerHTML = answer;
      
      const width = Math.max(40, answer.length*10);
      input.setAttribute('style', `width:${width}px;`);

      if (quizAlreadyCompleted || i < curQ) {
        if (quizAlreadyCompleted) {
          question.classList.remove('hidden');
        }
        input.value = decode(answer);
        completeQuestion(input);
      } else {
        // No point in setting a listener if the input is already completed
        input.onkeyup = (e) => { verifyAnswer(e); };
      }
    };

    document.querySelector('.openlinks').addEventListener('click', () => {
      openAllLinks();
    });

    // set up mobile behavior if mobile is visible
    if (isMobile) {
      document.querySelectorAll('button.mobile').forEach((el) => {
        el.addEventListener('click', () => {
          switchMobileQuestion(el);
        });
      });

      document.querySelector('.hide').addEventListener('click', (event) => {
        toggleTextVisibility(event.target);
      });

      // set up text fade-in
      window.setTimeout(() => {
        [
          document.querySelector('.header'),
          document.querySelector('.explanation'),
          document.querySelector('.quiz'),
        ].forEach((el) => {
          el.classList.remove('hidden');
        });
      }, 1500);
      window.setTimeout(() => {
        showText();
        // Show the button to control the text as well (but this will never hide again)
        document.querySelector('.hideContainer').classList.remove('invisible');
      }, 2000);
    } else {
      // If this is desktop, show the hidden text for good
      showText();
    }
  };

})();