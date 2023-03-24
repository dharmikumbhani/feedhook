import '../../css/styles.css'
import CloseIcon from '../Icons/CloseIcon'

export default function CloseButton() {
  return (
    <>
     <button className="close-button" type="button">
        <CloseIcon />
    </button>
    </>
  )
}