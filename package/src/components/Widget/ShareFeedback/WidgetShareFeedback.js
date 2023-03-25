import '../../../css/styles.css'
import CloseButton from '../../CloseButton/CloseButton'
import Button from '../../Button/Button'
import ModalHeading from '../../ModalHeading/ModalHeading'
import Footer from '../../Footer/Footer'
import TextAreaInput from '../../TextAreaInput/TextAreaInput'
import { useEffect, useState } from 'react'

export default function WidgetShareFeedback(props) {
  const [feedbackText, setFeedbackText] = useState()
  const [sendButtonClicked, setSendButtonClicked] = useState(false)
  const [loading, setLoading] = useState(false)
  const [successfulAttestation, setSuccessfulAttestation] = useState(false)

  useEffect(() => {
    if (sendButtonClicked) {
      // Here is where we can send the signing request along with data from feedback text
      console.log('submit button clicked state', sendButtonClicked, 'with feedback as', feedbackText)
    } else {
      console.log('Waiting for submit button to be clicked feedback text in useEffect', feedbackText)
    }
  }, [feedbackText, sendButtonClicked])

  const onClickButtonFunction = () => {
    setSendButtonClicked(true)
    // Here is where we can send the signing request along with data from feedback text
    console.log('Button Clicked!!')
    // Make sure to make the widget disappear or unmount once the button click function and signing is done
  }

  return (
    <>
    <div className='widget-container'>
        <CloseButton />
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
              <Button onClickButtonFunction={onClickButtonFunction} buttonTitle="Send" />
          </div>
        )}
        <Footer />
    </div>
    </>
  )
}