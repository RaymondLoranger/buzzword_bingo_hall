// Used in the new session form to set the "player_color" hidden
// input field value to the selected color. Also updates the
// border color of the "player_name" input field, just for style points.

const colors = document.querySelectorAll("#color-selector .color")

colors.forEach(color => {
  color.addEventListener('click', function() {
    const currentlySelected =
      document.querySelector("#color-selector .color.selected")
    currentlySelected.classList.remove('selected')
    this.classList.add('selected')
    const selectedColor = this.style.backgroundColor
    const playerColor = document.querySelector("#player_color")
    playerColor.value = selectedColor
    const playerName = document.querySelector("#player_name")
    playerName.style.borderColor = selectedColor
  })
})

// Or if you prefer jQuery, here's the equivalent:

/*
<script
  src="https://code.jquery.com/jquery-3.2.1.min.js"
  integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
  crossorigin="anonymous"></script>

$("#color-selector .color").click(function() {
  $(this)
    .addClass("selected")
    .siblings()
    .removeClass("selected")
  const color = $(this).css("background-color")
  $("#player_color").val(color)
  $("#player_name").css("border-color", color)
})
*/
