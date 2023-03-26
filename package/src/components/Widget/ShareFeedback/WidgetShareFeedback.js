import '../../../css/styles.css'
import CloseButton from '../../CloseButton/CloseButton'
import Button from '../../Button/Button'
import ModalHeading from '../../ModalHeading/ModalHeading'
import Footer from '../../Footer/Footer'
import TextAreaInput from '../../TextAreaInput/TextAreaInput'
import { useEffect, useState, useRef } from 'react'

export default function WidgetShareFeedback(props) {
  const [feedbackText, setFeedbackText] = useState()
  const [sendButtonClicked, setSendButtonClicked] = useState(false)
  const [loading, setLoading] = useState(false)
  const [successfulAttestation, setSuccessfulAttestation] = useState(false)

  const widgetContainerRef = useRef(null);

  const onCloseButtonClicked = () => {
    widgetContainerRef.current.classList.add('close-widget')
    console.log('close Button Clicked')
  }

  useEffect(() => {
    if (sendButtonClicked) {
      // Here is where we can send the signing request along with data from feedback text
      console.log('submit button clicked state in useState', sendButtonClicked, 'with feedback as', feedbackText)
    } else {
      console.log('Waiting for submit button to be clicked feedback text in useEffect', feedbackText)
    }
  }, [feedbackText, sendButtonClicked])


  return (
    <>
    <div ref={widgetContainerRef} className='widget-container'>
        <CloseButton onCloseButtonClicked={onCloseButtonClicked} />
        <ModalHeading heading="Share Feedback" />
        {successfulAttestation ? (
          <div className="successful-container">
            <p>Attestation successfully recorded!</p>
          </div>
        ) : loading ? (
          <div className='loading-container'>
            <LoadingSVG />
          </div>
        ) : (
          <div className="buttons-container">
              <TextAreaInput setFeedbackText={setFeedbackText} />
              <Button onClickButtonFunction={() => {setSendButtonClicked(true); props.callback(feedbackText)}} buttonTitle="Send" />
          </div>
        )}
        <Footer />
    </div>
    </>
  )
}