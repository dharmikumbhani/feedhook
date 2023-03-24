import React from "react";
import {storiesOf} from '@storybook/react';
import WidgetPageHelpful from "../components/Widget/PageHelpful/WidgetPageHelpful";
import EmojiButton from "../components/EmojiButton/EmojiButton";

const stories = storiesOf('Widget Test', module)

stories.add('Widget', () => {
    return (
        <>
            <WidgetPageHelpful />
            <EmojiButton />
        </>
    );
})