import '../../css/styles.css'
import CloseIcon from '../Icons/CloseIcon'

export default function CloseButton(props) {
  return (
    <>
     <button onClick={props.onCloseButtonClicked} className="close-button" type="button">
        <CloseIcon />
    </button>
    </>
  )
}