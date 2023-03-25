import '../../../css/styles.css'
import CloseButton from '../../CloseButton/CloseButton'
import Button from '../../Button/Button'
import ModalHeading from '../../ModalHeading/ModalHeading'
import Footer from '../../Footer/Footer'
import { useEffect, useState } from 'react'
import LoadingSVG from '../../LoadingSVG/LoadingSVG'

export default function WidgetPageHelpful(props) {
  const [pageHelpful, setPageHelpful] = useState();
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    // Here is where we can send the signing request along with data from feedback text
    console.log('pageHelpful in useEffect', pageHelpful)
    // Make sure to make the widget disappear or unmount once the button click function and signing is done
  }, [pageHelpful])
  const onCloseButtonClicked = () => {
    console.log('close Button Clicked')
  }
  return (
    <>
    <div className='widget-container page-helpful-widget'>
        <CloseButton onCloseButtonClicked={onCloseButtonClicked} />
        <ModalHeading heading="Is this page helpful?" />
        {loading ? (
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
    </>
  )
}