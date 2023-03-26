import '../../css/styles.css'
import WidgetPageHelpful from './PageHelpful/WidgetPageHelpful'
import WidgetRateExperience from './RateExperience.js/WidgetRateExperience'
import WidgetShareFeedback from './ShareFeedback/WidgetShareFeedback'

export const FeedhookWidget = (props) => {
  return (
    <>
    {
    props.widgetType === "pageHelpful" ? (
        <WidgetPageHelpful />
    ) :
        props.widgetType === 'rateExperience' ? (
            <WidgetRateExperience />
        ) :
        props.widgetType === 'shareFeedback' ? (
            <WidgetShareFeedback />
        ) : (
            <h1>Please enter the correct widgetType</h1>
        )
    }
    </>
  )
}