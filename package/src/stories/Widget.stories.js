import React from "react";
import {storiesOf} from '@storybook/react';
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