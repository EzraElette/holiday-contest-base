$(function () {
  $('.vote-button').click(function (event) {
    let request = new XMLHttpRequest();
      // $(event.target).closest('figure').find('img').attr('id')
    request.open('POST', '/vote')

    request.addEventListener('load', function () {
      let $voteCount = $(event.target).parent('.vote-area').find('.vote-count');
      const p = document.createElement('p');

      $voteCount.text((+$voteCount.text() + 1) + '');
      p.textContent = 'voted';

      console.log(event.currentTarget);
      $(event.currentTarget)[0].replaceWith(p);
    });

    let data = $(event.target).data('id');

    request.addEventListener('error', () => {
      console.log('error');
    });

    request.send(data);
  });

  let $imageInput = $('#image');

  $imageInput.change(function () {

    let selection = $('#image')[0].files[0];
    const fileReader = new FileReader();

    fileReader.addEventListener('load', (event) => {
      let string = event.target.result;

      document.getElementById('imageData').value = string;
    });

    fileReader.readAsDataURL(selection);
  });
});