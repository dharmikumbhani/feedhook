import "../../css/styles.css";
import WidgetPageHelpful from "./PageHelpful/WidgetPageHelpful";
import WidgetRateExperience from "./RateExperience.js/WidgetRateExperience";
import WidgetShareFeedback from "./ShareFeedback/WidgetShareFeedback";

export const FeedhookWidget = (props) => {
    return (
        <>
        {props.widgetType === "pageHelpful" ? (
            <WidgetPageHelpful callback={props.callback} />
        ) : props.widgetType === "rateExperience" ? (
            <WidgetRateExperience callback={props.callback} />
        ) : props.widgetType === "shareFeedback" ? (
            <WidgetShareFeedback callback={props.callback} />
        ) : (
            <WidgetPageHelpful callback={props.callback} />
        )}
        </>
    );
};
