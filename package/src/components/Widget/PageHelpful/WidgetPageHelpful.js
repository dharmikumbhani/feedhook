import '../../../css/styles.css'
import CloseButton from '../../CloseButton/CloseButton'
import Button from '../../Button/Button'
import ModalHeading from '../../ModalHeading/ModalHeading'
import Footer from '../../Footer/Footer'
import { useEffect, useState, useRef } from 'react'
import LoadingSVG from '../../LoadingSVG/LoadingSVG'

export default function WidgetPageHelpful(props) {
  const [pageHelpful, setPageHelpful] = useState();
  const [loading, setLoading] = useState(false);
  const [successfulAttestation, setSuccessfulAttestation] = useState(false);

  const widgetContainerRef = useRef(null);

  const onCloseButtonClicked = () => {
    widgetContainerRef.current.classList.add('close-widget')
    console.log('close Button Clicked')
  }

  useEffect(() => {
    // Here is where we can send the signing request along with data from pageHelpful
    console.log('pageHelpful in useEffect', pageHelpful)
    props.callback(pageHelpful)
    // Make sure to make the widget disappear or unmount once the button click function and signing is done
  }, [pageHelpful])

  return (
    <>
    {/* <div className='widget-backdrop'> */}
    <div ref={widgetContainerRef} className='widget-container page-helpful-widget'>
        <CloseButton onCloseButtonClicked={onCloseButtonClicked} />
        <ModalHeading heading="Is this page helpful?" />
        {
          successfulAttestation ? (
            <div className="successful-container">
              <p>Attestation successfully recorded!</p>
            </div>
          ) : loading ? (
          <div className='loading-container'>
            <LoadingSVG />
          </div>
        ): (
          <div className="flex-horizontal buttons-container">
              <Button onClickButtonFunction={()=> {setPageHelpful(true)}} buttonTitle="Yes" />
              <Button onClickButtonFunction={()=> {setPageHelpful(false)}} buttonTitle="No" />
          </div>
        )}
        <Footer />
    </div>
    {/* </div> */}
    </>
  )
}