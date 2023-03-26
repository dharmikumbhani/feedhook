import "../../../css/styles.css";
import CloseButton from "../../CloseButton/CloseButton";
import Button from "../../Button/Button";
import ModalHeading from "../../ModalHeading/ModalHeading";
import Footer from "../../Footer/Footer";
import EmojiButton from "../../EmojiButton/EmojiButton";
import { useEffect, useState, useRef } from "react";

export default function WidgetRateExperience(props) {
  const arrayOfEmotions = [
    { emotion: "angry", value: "-2" },
    { emotion: "sad", value: "-1" },
    { emotion: "neutral", value: "0" },
    { emotion: "happy", value: "1" },
    { emotion: "struck", value: "2" },
  ];

  const [ratingValue, setRatingValue] = useState();
  const [loading, setLoading] = useState(false);
  const [successfulAttestation, setSuccessfulAttestation] = useState(false);

  const widgetContainerRef = useRef(null);

  const onCloseButtonClicked = () => {
    widgetContainerRef.current.classList.add('close-widget')
    console.log('close Button Clicked')
  }


  useEffect(() => {
    // Here is where we can send the signing request along with data from feedback text
    console.log("Rating Value in use Effect", ratingValue);
    // Make sure to make the widget disappear or unmount once the button click function and signing is done
  }, [ratingValue]);

  return (
    <>
      <div ref={widgetContainerRef} className="widget-container">
        <CloseButton onCloseButtonClicked={onCloseButtonClicked} />
        <ModalHeading heading="Rate Your Experience" />
        {successfulAttestation ? (
          <div className="successful-container">
            <p>Attestation successfully recorded!</p>
          </div>
        ) : loading ? (
          <div className="loading-container">
            <LoadingSVG />
          </div>
        ) : (
          <div className="flex-horizontal buttons-container">
            {arrayOfEmotions.map((arrayObject, key) => (
              <EmojiButton
                onClickButtonFunction={() => {setRatingValue(arrayObject.value); props.callback(arrayObject.value)}}
                arrayObject={arrayObject}
                setRatingValue={setRatingValue}
                emotion={arrayObject.emotion}
                key={key}
              />
            ))}
          </div>
        )}
        <Footer />
      </div>
    </>
  );
}
