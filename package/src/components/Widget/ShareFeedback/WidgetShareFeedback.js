import '../../../css/styles.css'
import CloseButton from '../../CloseButton/CloseButton'
import Button from '../../Button/Button'
import ModalHeading from '../../ModalHeading/ModalHeading'
import Footer from '../../Footer/Footer'
import TextAreaInput from '../../TextAreaInput/TextAreaInput'

export default function WidgetShareFeedback(props) {
  return (
    <>
    <div className='widget-container'>
        <CloseButton />
        <ModalHeading heading="Share Feedback" />
        <div className="buttons-container">
            <TextAreaInput />
            <Button buttonTitle="Send" />
        </div>
        <Footer />
    </div>
    </>
  )
}