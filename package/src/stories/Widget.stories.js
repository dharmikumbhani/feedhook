import React from "react";
import {storiesOf} from '@storybook/react';
import WidgetPageHelpful from "../components/Widget/PageHelpful/WidgetPageHelpful";
import EmojiButton from "../components/EmojiButton/EmojiButton";
import WidgetRateExperience from "../components/Widget/RateExperience.js/WidgetRateExperience";
import WidgetShareFeedback from "../components/Widget/ShareFeedback/WidgetShareFeedback";
import FeedhookWidget from "../components/Widget/FeedhookWidget";

const stories = storiesOf('Widget Test', module)

stories.add('Widget', () => {
    return (
        <>
            <FeedhookWidget widgetType="pageHelpful" />
            <FeedhookWidget widgetType="rateExperience" />
            <FeedhookWidget widgetType="shareFeedback" />
        </>
    );
})