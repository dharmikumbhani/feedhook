import React from "react";
import {storiesOf} from '@storybook/react';
import FeedhookWidget from "../components/Widget/FeedhookWidget";

const stories = storiesOf('Widget Test', module)

stories.add('Widget', () => {
    const callback = (value) => {
        console.log('callback was hit with this value', value)
    }
    return (
        <>
            <FeedhookWidget callback={callback} widgetType="pageHelpful" />
            <FeedhookWidget widgetType="rateExperience" />
            <FeedhookWidget widgetType="shareFeedback" />
        </>
    );
})