(() => { 
  let score;
  let completed = 0;
  let numQs;
  let usedhint = 'no';
  const cookiename = 'lastcompleted';

  function decode(str) {
    const input = 'nopqrstuvwxyz0123456789abcdefghijklm';
    const output = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var translate = x => input.indexOf(x) > -1 ? output[input.indexOf(x)] : x;
    return str.split('').map(translate).join('');
  }
  
  function getMiniDateStr(date) {
    let m = date.getMonth() + 1;
    m = m.length < 2 ? `0${m}` : m;
    let d = date.getDate();
    d = d.length < 2 ? `0${d}` : d; 
    return `${m}-${d}-${date.getFullYear()}`;
  }

  function completeQuiz() {
    const finished = document.querySelector('.finished');
    if (usedhint === 'yes') {
      finished.innerText = '100% (with hints)';
    }
    finished.classList.remove('invisible');

    // Add completed date to cookie - value is today's date as a string
    const completedDate = getMiniDateStr(new Date());
    updateCookie(`${cookiename}=${completedDate}`);
  }

  function updateCookie(newCookieStr) {
    const today = new Date();
    // Expires today at midnight
    const date = new Date(`${today.getMonth() + 1} ${today.getDate()} ${today.getFullYear()} 23:59:59`);
    const expires = date.toUTCString();
    
    document.cookie = `${newCookieStr};expires=${expires};path=/`;
  }

  // Also updates the usedHint variable
  function hasQuizAlreadyBeenCompleted() {
    const cookies = document.cookie.split('; ');
    let ret = false;
    for (let i = 0; i < cookies.length; i++) {
      const parts = cookies[i].split('=');
      if (parts[0] === 'usedhint') {
        usedhint = parts[1];
      } else if (parts[0] === cookiename) {  
        const lastDate = parts[1];
        const today = new Date();
        ret = lastDate === getMiniDateStr(today);
      }
    }
    return ret;
  }

  function completeQuestion(input) {
    input.classList.add('completed');
    input.setAttribute('disabled','true');
    completed++;
    score.querySelector('span.num').innerHTML = completed;
    
    const hint = input.parentElement.querySelector('.hint');
    if (hint.classList.contains('isFakeLink')) {
      // hide unused hints
      hint.classList.add('hidden');
    }

    if (completed >= numQs) {
      completeQuiz();
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
    const questions = document.querySelectorAll('.question');
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

  function revealHint(hint) {
    hint.classList.remove('isFakeLink');
    hint.innerText = `[Check ${hint.getAttribute('linkhint')}]`;
    usedhint = 'yes';
    updateCookie(`usedhint=${usedhint}`);
  }

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

    document.querySelector('.openlinks').addEventListener('click', () => {
      openAllLinks();
    });

    document.querySelectorAll('.hint').forEach((hint) => {
      hint.addEventListener('click', () => {
        revealHint(hint);
      });
    });

    // set up mobile behavior if mobile is visible
    if (document.querySelector('.mobile').computedStyleMap().get('display').value === 'block') {
      document.querySelectorAll('button.mobile').forEach((el) => {
        el.addEventListener('click', () => {
          switchMobileQuestion(el);
        });
      });

      let first = true;
      document.querySelectorAll('.question').forEach((el) => {
        if (first) {
          first = false;
        } else {
          el.classList.add('hidden');
        }
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