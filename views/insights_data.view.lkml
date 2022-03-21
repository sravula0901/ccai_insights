view: insights_data {
  sql_table_name: @{INSIGHTS_TABLE} ;;
  view_label: "1: Conversations"

  dimension: agent_id {
    type: string
    description: "The user-provided identifier for the human agent who handled the conversation."
    sql: ${TABLE}.agentId ;;
    link: {
      label: "Agent Performance Dashboard"
      url: "/dashboards-next/insights_demo::agent_performance?Agent+ID={{ value}}&Import+Date={{ _filters['insights_data.load_date'] | url_encode }}&Start+Date={{ _filters['insights_data.start_date'] | url_encode }}&Type={{ _filters['insights_data.type'] | url_encode }}&Client+Sentiment+Category={{ _filters['insights_data.client_sentiment_category'] | url_encode }}"
    }
  }

  dimension: agent_sentiment_magnitude {
    group_label: "Sentiment"
    type: number
    description: "A non-negative number from zero to infinity that represents the abolute magnitude of the agent sentiment regardless of score."
    sql: ${TABLE}.agentSentimentMagnitude ;;
  }

  dimension: agent_sentiment_score {
    group_label: "Sentiment"
    type: number
    description: "Agent sentiment score between -1.0 (negative) and 1.0 (positive)."
    sql: ${TABLE}.agentSentimentScore ;;
  }

  dimension: agent_speaking_percentage {
    type: number
    description: "Percentage of the conversation with the agent speaking."
    sql: ${TABLE}.agentSpeakingPercentage ;;
    value_format_name: percent_2
  }

  dimension: audio_file_uri {
    type: string
    description: "Location of the audio file on GCS."
    sql: ${TABLE}.audioFileUri ;;
  }

  dimension: channel {
    description: "Voice or Chat"
    type: string
    sql: case when ${audio_file_uri} not null then "Voice" else when ${transcript} not null then "Chat" end ;;
  }
  dimension: client_sentiment_magnitude {
    group_label: "Sentiment"
    type: number
    description: "A non-negative number from zero to infinity that represents the abolute magnitude of client sentiment regardless of score."
    sql: ${TABLE}.clientSentimentMagnitude ;;
  }

  dimension: client_sentiment_score {
    group_label: "Sentiment"
    type: number
    description: "Client sentiment score between -1.0 (negative) and 1.0 (positive)."
    sql: ${TABLE}.clientSentimentScore ;;
  }

  dimension: client_speaking_percentage {
    type: number
    description: "Percentage of the conversation with the client speaking."
    sql: ${TABLE}.clientSpeakingPercentage ;;
    value_format_name: percent_2
  }

  dimension: conversation_name {
    type: string
    primary_key: yes
    description: "Name of the conversation resource."
    sql: ${TABLE}.conversationName ;;
    link: {
      label: "Conversation Lookup Dashboard"
      url: "/dashboards-next/insights_demo::conversation_lookup?Conversation+Name={{ value}}"
    }
  }

  dimension: day {
    group_label: "Dates"
    hidden: yes
    type: number
    description: "Day date part of `load_timestamp_utc`."
    sql: ${TABLE}.day ;;
  }

  dimension: duration_nanos {
    hidden: yes
    type: number
    description: "Conversation duration in nanoseconds."
    sql: ${TABLE}.durationNanos;;
  }

  dimension: duration_seconds {
    hidden: yes
    type: number
    description: "Conversation duration in seconds."
    sql: CAST(${TABLE}.durationNanos/1000000000 as INT64);;
  }

  dimension: duration_minutes {
    hidden: yes
    type: number
    description: "Conversation duration in minutes."
    sql: CAST(${TABLE}.durationNanos/60000000000 as INT64);;
  }

  dimension: entities {
    hidden: yes
    sql: ${TABLE}.entities ;;
  }

  dimension: labels {
    hidden: yes
    sql: ${TABLE}.labels ;;
  }

  dimension_group: load {
    group_label: "Dates"
    label: "Import"
    type: time
    timeframes: [time, hour_of_day, date, day_of_week, week, month_name, year, raw]
    description: "The time in UTC at which the conversation was loaded into Insights."
    sql: TIMESTAMP_SECONDS(${TABLE}.loadTimestampUtc) ;;
  }

  dimension: month {
    group_label: "Dates"
    hidden: yes
    type: number
    description: "Month date part of `load_timestamp_utc`."
    sql: ${TABLE}.month ;;
  }

  dimension: sentences {
    hidden: yes
    sql: ${TABLE}.sentences ;;
  }

  dimension: silence_nanos {
    hidden: yes
    type: number
    description: "Number of nanoseconds calculated to be in silence."
    sql: ${TABLE}.silenceNanos ;;
  }

  dimension: silence_seconds {
    hidden: yes
    type: number
    description: "Number of seconds calculated to be in silence."
    sql: CAST(${TABLE}.silenceNanos/1000000000 as INT64);;
  }

  dimension: silence_minutes {
    type: number
    description: "Number of minutes calculated to be in silence."
    sql: CAST(${TABLE}.silenceNanos/60000000000 as INT64) ;;
  }

  dimension: silence_percentage {
    type: number
    description: "Percentage of the total conversation spent in silence."
    sql: ${TABLE}.silencePercentage ;;
    value_format_name: percent_2
  }

  dimension_group: start {
    group_label: "Dates"
    type: time
    timeframes: [time, hour_of_day, date, day_of_week, week, month_name, year, raw]
    description: "The time in UTC at which the conversation started."
    sql: TIMESTAMP_SECONDS(${TABLE}.startTimestampUtc) ;;
  }

  dimension_group: end {
    group_label: "Dates"
    type: time
    timeframes: [time, hour_of_day, date, day_of_week, week, month_name, year, raw]
    description: "The time in UTC at which the conversation ended."
    sql: TIMESTAMP_SECONDS(${TABLE}.startTimestampUtc+${duration_seconds}) ;;
  }

  dimension_group: conversation {
    description: "The time between conversation start and end."
    type: duration
    intervals: [second, minute, hour]
    sql_start: ${start_raw} ;;
    sql_end: ${end_raw} ;;
  }

  dimension: topics {
    hidden: yes
    sql: ${TABLE}.issues ;;
  }

  dimension: transcript {
    type: string
    description: "The complete text transcript of the conversation."
    sql: ${TABLE}.transcript ;;
  }

  dimension: turn_count {
    type: number
    description: "The number of turns taken in the conversation."
    sql: ${TABLE}.turnCount ;;
  }

  dimension: type {
    description: "If the call was never transferred to a human, then the call is classified as Virtual. If the call was transferred to a human, then the call is classified as human."
    type: string
    sql: case when ${human_agent_turns.first_turn_human_agent} is null then "Virtual Agent"
            else "Human Agent" end;;
  }

  dimension: status {
    description: "If the call was never transferred to a human, then Contained. If it was contained but lasted less than 1 minute, then Abandoned. If it was transferred to a human, then Transferred."
    type: string
    sql: case when ${human_agent_turns.first_turn_human_agent} is null and ${duration_minutes} < 1 then "Abandoned"
     when ${human_agent_turns.first_turn_human_agent} is null then "Contained"
      else "Transferred" end;;
  }

  dimension: words {
    hidden: yes
    sql: ${TABLE}.words ;;
  }

  dimension: year {
    group_label: "Dates"
    hidden: yes
    type: number
    description: "Year date part of `load_timestamp_utc`."
    sql: ${TABLE}.year ;;
  }

  ################## Sentiment Analysis ###########################
  #Configure manual score and magnitude thresholds here in the default_value parameter. To allow users to eadjust these values in the UI, set the hidden parameter to no.
  #Documentation to guide interpretation here:https://cloud.google.com/natural-language/docs/basics#interpreting_sentiment_analysis_values

  parameter: sentiment_score_threshold {
    description: "Score of the sentiment ranges between -1.0 (negative) and 1.0 (positive) and corresponds to the overall emotional leaning of the text. Set a custom minimum threshold to trigger Positive and Negative. E.g., choosing 0.05 will set Score > 0.05 to Positive, and Score < -0.05 to be Negative, while also incorporating the Magnitude selection."
    hidden:  no #Set no if you want this exposed in the Browse/Explore
    type: number
    default_value: "0.05"
  }
  parameter: sentiment_magnitude_threshold {
    description: "Magnitude indicates the overall strength of emotion (both positive and negative) within the given text, between 0.0 and +inf. Unlike score, magnitude is not normalized; each expression of emotion within the text (both positive and negative) contributes to the text's magnitude (so longer text blocks may have greater magnitudes). Set a custom minimum threshold to trigger Positive, Negative, and Mixed vs. Neutral. E.g., choosing 0.1 will allow Positive scores to be considered Positive (vs. Mixed) if Magnitude exceeds 0.1."
    hidden:  no #Set no if you want this exposed in the Browse/Explore
    type:  number
    default_value: "0.1"
  }

  dimension: client_sentiment_category {
    group_label: "Sentiment"
    type: string
    description: "Negative sentiment score is bad, 0 sentiment score is neutral, and positive sentiment score is good."
    sql: CASE
          WHEN ${client_sentiment_score} <= -{% parameter sentiment_score_threshold %} AND ${client_sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %}  THEN "Negative"
          WHEN ${client_sentiment_score} >= {% parameter sentiment_score_threshold %} AND ${client_sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Positive"
          WHEN (${client_sentiment_score} < {% parameter sentiment_score_threshold %} OR ${client_sentiment_score} > -{% parameter sentiment_score_threshold %})
          AND ${client_sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Mixed"
          ELSE "Neutral" END;;
  }

  dimension: agent_sentiment_category {
    group_label: "Sentiment"
    type: string
    description: "Negative sentiment score is bad, 0 sentiment score is neutral, and positive sentiment score is good."
    sql: CASE
          WHEN ${agent_sentiment_score} <= -{% parameter sentiment_score_threshold %} AND ${agent_sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %}  THEN "Negative"
          WHEN ${agent_sentiment_score} >= {% parameter sentiment_score_threshold %} AND ${agent_sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Positive"
          WHEN (${agent_sentiment_score} < {% parameter sentiment_score_threshold %} OR ${agent_sentiment_score} > -{% parameter sentiment_score_threshold %})
          AND ${agent_sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Mixed"
          ELSE "Neutral" END;;
  }

  dimension: client_sentiment_category_value {
    group_label: "Sentiment"
    description: "Sentiment score multiplied by sentiment magnitude"
    type: number
    hidden: yes
    sql: ${client_sentiment_score}*${client_sentiment_magnitude} ;;
    value_format_name: decimal_4
  }

  measure: average_client_sentiment_category_value{
    group_label: "Sentiment"
    type: average
    sql: ${client_sentiment_category_value} ;;
    value_format_name: decimal_4
  }

  dimension: agent_sentiment_category_value {
    group_label: "Sentiment"
    description: "Sentiment score multiplied by sentiment magnitude"
    type: number
    hidden: yes
    sql: ${agent_sentiment_score}*${agent_sentiment_magnitude} ;;
    value_format_name: decimal_4
  }

  measure: average_agent_sentiment_category_value{
    group_label: "Sentiment"
    type: average
    sql: ${agent_sentiment_category_value} ;;
    value_format_name: decimal_4
  }

  measure: bad_sentiment_conversation_count {
    label: "Negative Conversation Count"
    group_label: "Sentiment"
    description: "Based on client sentiment category"
    type: count
    filters: [client_sentiment_category: "Negative"]
    drill_fields: [convo_info*]
  }

  measure: good_sentiment_conversation_count {
    label: "Positive Conversation Count"
    group_label: "Sentiment"
    description: "Based on client sentiment category"
    type: count
    filters: [client_sentiment_category: "Positive"]
    drill_fields: [convo_info*]
  }

  measure: neutral_sentiment_conversation_count {
    label: "Neutral Conversation Count"
    group_label: "Sentiment"
    description: "Based on client sentiment category"
    type: count
    filters: [client_sentiment_category: "Neutral"]
    drill_fields: [convo_info*]
  }

  measure: mixed_sentiment_conversation_count {
    label: "Mixed Conversation Count"
    group_label: "Sentiment"
    description: "Based on client sentiment category"
    type: count
    filters: [client_sentiment_category: "Mixed"]
    drill_fields: [convo_info*]
  }

  measure: bad_sentiment_ratio {
    label: "Negative Conversation Ratio"
    description: "Negative Conversations / Total Conversations"
    group_label: "Sentiment"
    type: number
    sql: ${bad_sentiment_conversation_count}/${conversation_count} ;;
    value_format_name: percent_0
    drill_fields: [convo_info*]
  }

  measure: good_sentiment_ratio {
    label: "Positive Conversation Ratio"
    description: "Positive Conversations / Total Conversations"
    group_label: "Sentiment"
    type: number
    sql: ${good_sentiment_conversation_count}/${conversation_count} ;;
    value_format_name: percent_0
    drill_fields: [convo_info*]
  }

  measure: neutral_sentiment_ratio {
    label: "Neutral Conversation Ratio"
    description: "Neautral Conversations / Total Conversations"
    group_label: "Sentiment"
    type: number
    sql: ${neutral_sentiment_conversation_count}/${conversation_count} ;;
    value_format_name: percent_0
    drill_fields: [convo_info*]
  }

  measure: mixed_sentiment_ratio {
    label: "Mixed Conversation Ratio"
    description: "Mixed Conversations / Total Conversations"
    group_label: "Sentiment"
    type: number
    sql: ${mixed_sentiment_conversation_count}/${conversation_count} ;;
    value_format_name: percent_0
    drill_fields: [convo_info*]
  }

  measure: average_client_sentiment_score {
    group_label: "Sentiment"
    type: average
    sql: ${client_sentiment_score} ;;
    value_format_name: decimal_2
    drill_fields: [convo_info*,client_sentiment_score]
  }

  measure: average_client_sentiment_magnitude {
    group_label: "Sentiment"
    type: average
    sql: ${client_sentiment_magnitude} ;;
    value_format_name: decimal_2
    drill_fields: [convo_info*,client_sentiment_score, client_sentiment_magnitude]
  }

  measure: average_agent_sentiment_score {
    group_label: "Sentiment"
    type: average
    sql: ${agent_sentiment_score} ;;
    value_format_name: decimal_2
    drill_fields: [convo_info*,agent_sentiment_score]
  }

  measure: average_agent_sentiment_magnitude {
    group_label: "Sentiment"
    type: average
    sql: ${agent_sentiment_magnitude} ;;
    value_format_name: decimal_2
    drill_fields: [convo_info*,agent_sentiment_score, agent_sentiment_magnitude]
  }


### Measures ###
  measure: conversation_count {
    type: count
    drill_fields: [convo_info*]
  }

  measure: contained_count {
    description: "A conversation is considered contained if it was never passed to a human agent."
    type: count
    filters: [type: "Virtual Agent"]
    drill_fields: [convo_info*]
  }

  measure: contained_percentage {
    description: "A conversation is considered contained if it was never passed to a human agent."
    type: number
    sql: ${contained_count}/${conversation_count} ;;
    value_format_name: percent_0
    drill_fields: [convo_info*]
  }

  measure: num_of_characters {
    label: "Number of Characters"
    type: sum
    sql: length(${transcript}) ;;
  }

  measure: num_of_characters_no_space {
    label: "Number of Characters (no spaces)"
    type: sum
    sql: length(REGEXP_REPLACE(${transcript}, ' ', '')) ;;
  }

  measure: average_turn_count {
    type: average
    sql: ${turn_count} ;;
    value_format_name: decimal_0
    drill_fields: [convo_info*, turn_count]
  }

  measure: average_conversation_minutes {
    type: average
    sql: ${minutes_conversation} ;;
    value_format_name: decimal_0
    drill_fields: [convo_info*, duration_minutes]
  }

  measure: average_silence_percentage {
    type: average
    sql: ${silence_percentage} ;;
    value_format_name: percent_2
    drill_fields: [convo_info*, silence_percentage, silence_minutes]
  }

  measure: average_agent_speaking_percentage {
    type: average
    sql: ${agent_speaking_percentage} ;;
    value_format_name: percent_2
    drill_fields: [convo_info*, agent_speaking_percentage]
  }

  measure: average_client_speaking_percentage {
    type: average
    sql: ${client_speaking_percentage} ;;
    value_format_name: percent_2
    drill_fields: [convo_info*, client_speaking_percentage]
  }

 set: convo_info {
   fields: [agent_id, conversation_name, turn_count, load_time, duration_minutes, type, client_sentiment_category, agent_sentiment_category, status]
 }
}

view: insights_data__words {
  dimension: end_offset_nanos {
    hidden: yes
    type: number
    description: "Time offset in nanoseconds of the end of this word relative to the beginning of the conversation."
    sql: ${TABLE}.endOffsetNanos ;;
  }

  dimension: language_code {
    type: string
    description: "Language code."
    sql: ${TABLE}.languageCode ;;
  }

  dimension: speaker_tag {
    type: number
    description: "The speaker that the word originated from."
    sql: ${TABLE}.speakerTag ;;
  }

  dimension: start_offset_nanos {
    hidden: yes
    type: number
    description: "Time offset in nanoseconds of the start of this word relative to the beginning of the conversation."
    sql: ${TABLE}.startOffsetNanos ;;
  }

  dimension: word {
    primary_key: yes
    type: string
    description: "The transcribed word."
    sql: ${TABLE}.word ;;
  }

  measure: count {
    type: count_distinct
    sql: ${word} ;;
  }
}

view: insights_data__labels {
  dimension: key {
    label: "Label Key"
    group_label: "Labels"
    type: string
    description: "User-provided label key."
    sql: ${TABLE}.key ;;
  }

  dimension: value {
    label: "Label Value"
    group_label: "Labels"
    type: string
    description: "User-provided label value."
    sql: ${TABLE}.value ;;
  }
}

view: insights_data__topics {
  dimension: name {
    label: "Topic Name"
    group_label: "Topics"
    type: string
    description: "Name of the topic."
    sql: ${TABLE}.name ;;
  }

  dimension: score {
    label: "Topic Score"
    group_label: "Topics"
    type: number
    description: "Score indicating the likelihood of the topic assignment, between 0 and 1.0."
    sql: ${TABLE}.score ;;
  }

  measure: count {
    label: "Topic Count"
    group_label: "Topics"
    type: count_distinct
    sql: ${name} ;;
    drill_fields: [topic_detail*]
  }

  set: topic_detail {
    fields:[name, score]
    }
}

view: insights_data__entities {
  dimension: name {
    type: string
    description: "Name of the entity."
    sql: ${TABLE}.name ;;
  }

  dimension: salience {
    type: number
    description: "Salience score of the entity."
    sql: ${TABLE}.salience ;;
  }

  dimension: sentiment_magnitude {
    group_label: "Sentiment"
    type: number
    description: "A non-negative number from zero to infinity that represents the abolute magnitude of the entity sentiment regardless of score."
    sql: ${TABLE}.sentimentMagnitude ;;
  }

  dimension: sentiment_score {
    group_label: "Sentiment"
    type: number
    description: "The entity sentiment score between -1.0 (negative) and 1.0 (positive)."
    sql: ${TABLE}.sentimentScore ;;
  }

  dimension: speaker_tag {
    type: number
    description: "The speaker that the entity mention originated from."
    sql: ${TABLE}.speakerTag ;;
  }

  dimension: type {
    type: string
    description: "Type of the entity."
    sql: ${TABLE}.type ;;
  }

  ########################### Sentiment Analysis ############################
  #Configure manual score and magnitude thresholds here in the default_value parameter. To allow users to eadjust these values in the UI, set the hidden parameter to no.
  #Documentation to guide interpretation here:https://cloud.google.com/natural-language/docs/basics#interpreting_sentiment_analysis_values

  parameter: sentiment_score_threshold {
    description: "Score of the sentiment ranges between -1.0 (negative) and 1.0 (positive) and corresponds to the overall emotional leaning of the text. Set a custom minimum threshold to trigger Positive and Negative. E.g., choosing 0.05 will set Score > 0.05 to Positive, and Score < -0.05 to be Negative, while also incorporating the Magnitude selection."
    hidden:  no #Set no if you want this exposed in the Browse/Explore
    type: number
    default_value: "0.05"
  }
  parameter: sentiment_magnitude_threshold {
    description: "Magnitude indicates the overall strength of emotion (both positive and negative) within the given text, between 0.0 and +inf. Unlike score, magnitude is not normalized; each expression of emotion within the text (both positive and negative) contributes to the text's magnitude (so longer text blocks may have greater magnitudes). Set a custom minimum threshold to trigger Positive, Negative, and Mixed vs. Neutral. E.g., choosing 0.1 will allow Positive scores to be considered Positive (vs. Mixed) if Magnitude exceeds 0.1."
    hidden:  no #Set no if you want this exposed in the Browse/Explore
    type:  number
    default_value: "0.1"
  }
  dimension: sentiment_category {
    group_label: "Sentiment"
    type: string
    description: "Negative sentiment score is bad, 0 sentiment score is neutral, and positive sentiment score is good."
    sql: CASE
          WHEN ${sentiment_score} <= -{% parameter sentiment_score_threshold %} AND ${sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %}  THEN "Negative"
          WHEN ${sentiment_score} >= {% parameter sentiment_score_threshold %} AND ${sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Positive"
          WHEN (${sentiment_score} < {% parameter sentiment_score_threshold %} OR ${sentiment_score} > -{% parameter sentiment_score_threshold %})
          AND ${sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Mixed"
          ELSE "Neutral" END;;
  }
  measure: average_sentiment_score {
    group_label: "Sentiment"
    type: average
    sql: ${sentiment_score} ;;
    value_format_name: decimal_2
  }
  measure: average_sentiment_magnitude {
    group_label: "Sentiment"
    type: average
    sql: ${sentiment_magnitude} ;;
    value_format_name: decimal_2
  }
  dimension: sentiment_category_value {
    description: "Sentiment score multiplied by sentiment magnitude"
    type: number
    group_label: "Sentiment"
    sql: ${sentiment_score}*${sentiment_magnitude} ;;
    value_format_name: decimal_4
  }

  measure: average_sentiment_category_value{
    type: average
    group_label: "Sentiment"
    sql: ${sentiment_category_value} ;;
    value_format_name: decimal_4
  }


  ############################ Measures ##################################

  measure: count {
    type: count_distinct
    sql: ${name} ;;
    drill_fields: [entity_detail*]
  }

  measure: average_salience {
    type: average
    sql: ${salience} ;;
    drill_fields: [entity_detail*]
  }

  set: entity_detail {
    fields: [name,type,speaker_tag,sentiment_score, sentiment_magnitude,salience]
  }
}

view: insights_data__sentences {
  dimension: annotations {
    hidden: yes
    sql: ${TABLE}.annotations ;;
  }

  dimension_group: created {

    type: time
    timeframes: [time, minute, minute5, hour_of_day, date, day_of_week, week, month_name, year, raw]
    description: "Time in UTC that the conversation message took place, if provided."
    sql: TIMESTAMP_MICROS(CAST(${TABLE}.createTimeNanos/1000 as INT64)) ;;
  }

  dimension: dialogflow_intent_match_data {
    hidden: yes
    sql: ${TABLE}.dialogflowIntentMatchData ;;
  }

  dimension: end_offset_nanos {
    hidden: yes
    type: number
    description: "Time offset in nanoseconds of the end of this sentence relative to the beginning of the conversation."
    sql: ${TABLE}.endOffsetNanos ;;
  }

  dimension: intent_match_data {
    hidden: yes
    sql: ${TABLE}.intentMatchData ;;
  }

  dimension: is_covered_by_smart_reply_allowlist {
    type: yesno
    description: "Whether this message is covered by a configured allowlist in Agent Assist."
    sql: ${TABLE}.isCoveredBySmartReplyAllowlist ;;
  }

  dimension: language_code {
    type: string
    description: "Language code."
    sql: ${TABLE}.languageCode ;;
  }

  dimension: obfuscated_external_user_id {
    type: string
    description: "Customer provided obfuscated external user ID for billing purposes."
    sql: ${TABLE}.obfuscatedExternalUserId ;;
  }

  dimension: participant_id {
    type: string
    description: "Participant ID, if provided."
    sql: ${TABLE}.participantId ;;
  }

  dimension: participant_role {
    type: string
    description: "Participant role, if provided."
    suggestions: ["Virtual Agent","Human Agent","Client"]
    sql: case when ${TABLE}.participantRole='AUTOMATED_AGENT' then 'Virtual Agent'
            when ${TABLE}.participantRole='HUMAN_AGENT' then 'Human Agent'
            when ${TABLE}.participantRole='END_USER' then 'Client'
            else ${TABLE}.participantRole end;;
  }

  dimension: phrase_match_data {
    hidden: yes
    sql: ${TABLE}.phraseMatchData ;;
  }

  dimension: sentence {
    primary_key: yes
    type: string
    description: "The transcribed sentence."
    sql: ${TABLE}.sentence ;;
  }

  dimension: sentiment_magnitude {
    group_label: "Sentiment"
    type: number
    description: "A non-negative number from zero to infinity that represents the abolute magnitude of the sentence sentiment regardless of score."
    sql: ${TABLE}.sentimentMagnitude ;;
  }

  dimension: sentiment_score {
    group_label: "Sentiment"
    type: number
    description: "The sentence sentiment score between -1.0 (negative) and 1.0 (positive)."
    sql: ${TABLE}.sentimentScore ;;
  }

  dimension: speaker_tag {
    type: number
    description: "The speaker that the sentence originated from."
    sql: ${TABLE}.speakerTag ;;
  }

  dimension: start_offset_nanos {
    hidden: yes
    type: number
    description: "Time offset in nanoseconds of the start of this sentence relative to the beginning of the conversation."
    sql: ${TABLE}.startOffsetNanos ;;
  }

  dimension: is_sentence_before_transfer_human {
    description: "Identifies the sentence right before the call was transferred to a human agent."
    type: yesno
    sql: ${human_agent_turns.first_turn_human_agent} = ${sentence_turn_number.turn_number}-1;;
  }

  ############################ Sentiment Analysis #######################
#Configure manual score and magnitude thresholds here in the default_value parameter. To allow users to eadjust these values in the UI, set the hidden parameter to no.
#Documentation to guide interpretation here:https://cloud.google.com/natural-language/docs/basics#interpreting_sentiment_analysis_values

  parameter: sentiment_score_threshold {
    description: "Score of the sentiment ranges between -1.0 (negative) and 1.0 (positive) and corresponds to the overall emotional leaning of the text. Set a custom minimum threshold to trigger Positive and Negative. E.g., choosing 0.05 will set Score > 0.05 to Positive, and Score < -0.05 to be Negative, while also incorporating the Magnitude selection."
    hidden:  no #Set no if you want this exposed in the Browse/Explore
    type: number
    default_value: "0.05"
  }
  parameter: sentiment_magnitude_threshold {
    description: "Magnitude indicates the overall strength of emotion (both positive and negative) within the given text, between 0.0 and +inf. Unlike score, magnitude is not normalized; each expression of emotion within the text (both positive and negative) contributes to the text's magnitude (so longer text blocks may have greater magnitudes). Set a custom minimum threshold to trigger Positive, Negative, and Mixed vs. Neutral. E.g., choosing 0.1 will allow Positive scores to be considered Positive (vs. Mixed) if Magnitude exceeds 0.1."
    hidden:  no #Set no if you want this exposed in the Browse/Explore
    type:  number
    default_value: "0.1"
  }
  dimension: sentiment_category {
    group_label: "Sentiment"
    type: string
    description: "Negative sentiment score is bad, 0 sentiment score is neutral, and positive sentiment score is good."
    sql: CASE
          WHEN ${sentiment_score} <= -{% parameter sentiment_score_threshold %} AND ${sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %}  THEN "Negative"
          WHEN ${sentiment_score} >= {% parameter sentiment_score_threshold %} AND ${sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Positive"
          WHEN (${sentiment_score} < {% parameter sentiment_score_threshold %} OR ${sentiment_score} > -{% parameter sentiment_score_threshold %})
          AND ${sentiment_magnitude} > {% parameter sentiment_magnitude_threshold %} THEN "Mixed"
          ELSE "Neutral" END;;
  }

dimension: sentiment_category_value {
    description: "Sentiment score multiplied by sentiment magnitude"
    type: number
    group_label: "Sentiment"
    sql: ${sentiment_score}*${sentiment_magnitude} ;;
    value_format_name: decimal_4
}

measure: average_sentiment_category_value{
  type: average
  group_label: "Sentiment"
  sql: ${sentiment_category_value} ;;
  value_format_name: decimal_4
}

  measure: average_sentiment_score {
    group_label: "Sentiment"
    type: average
    sql: ${sentiment_score} ;;
    value_format_name: decimal_2
  }

  measure: average_sentiment_magnitude {
    group_label: "Sentiment"
    type: average
    sql: ${sentiment_magnitude} ;;
    value_format_name: decimal_2
  }

  ############################# Measures ##################################

  measure: count {
    type: count_distinct
    sql: ${sentence} ;;
  }

  measure: num_of_characters_sentence {
    label: "Number of Characters in Sentence"
    type: sum
    sql: length(${sentence}) ;;
  }

}

view: insights_data__sentences__annotations {
  label: "Insights Data: Sentences"

  dimension: clicked {
    group_label: "Agent Assist Annotations"
    type: yesno
    description: "Customer feedback on whether the suggestion was clicked."
    sql: ${TABLE}.clicked ;;
  }

  dimension: correctness_level {
    group_label: "Agent Assist Annotations"
    type: string
    description: "Customer feedback on the correctness level of the suggestion."
    sql: ${TABLE}.correctnessLevel ;;
  }

  dimension_group: create {
    group_label: "Agent Assist Annotations"
    hidden: yes
    type: time
    timeframes: [time, hour_of_day, date, day_of_week, week, month_name, year, raw]
    description: "The time in UTC when the suggestion was generated."
    sql: TIMESTAMP_MICROS(CAST(${TABLE}.createTimeNanos/1000 as INT64)) ;;
  }

  dimension: displayed {
    group_label: "Agent Assist Annotations"
    type: yesno
    description: "Customer feedback on whether the suggestion was displayed."
    sql: ${TABLE}.displayed ;;
  }

  dimension: record {
    group_label: "Agent Assist Annotations"
    type: string
    description: "The suggestion content returned from CCAI, serialised as JSON."
    sql: ${TABLE}.record ;;
  }

  dimension: type {
    group_label: "Agent Assist Annotations"
    type: string
    description: "The type of suggestion."
    sql: ${TABLE}.type ;;
  }
}

view: insights_data__sentences__intent_match_data {
  #Documentation on Smart Highllights Here: https://cloud.google.com/contact-center/insights/docs/smart-highlights
  dimension: display_name {
    #group_label: "Smart Highlights"
    label: "Smart Highlight Name"
    type: string
    description: "The human readable name of the matched intent."
    sql: case when ${TABLE}.displayName is null then "No Smart Highlight Match" else ${TABLE}.displayName end ;;
  }

  dimension: intent_id {
    group_label: "Smart Highlights"
    label: "Smart Highlight ID"
    type: string
    primary_key: yes
    hidden: yes
    description: "The unique ID of the matched intent."
    sql: ${TABLE}.intentId ;;
  }

  measure: count {
    label: "Smart Highlight Count"
    #group_label: "Smart Highlights"
    type: count
  }
}

view: insights_data__sentences__phrase_match_data {
  dimension: display_name {
    label: "Custom Highlight Name"
    #group_label: "Custom Highlights"
    type: string
    description: "The human readable name of the phrase matcher set up as a custom highlight in the Insights console."
    sql: case when ${TABLE}.displayName is null then "No Custom Highlight Match" else ${TABLE}.displayName end ;;
  }

  dimension: phrase_matcher_id {
    primary_key: yes
    group_label: "Custom Highlights"
    label: "Custom Highlight ID"
    type: string
    hidden: yes
    description: "The unique ID of the phrase matcher set up as a custom highlight in the Insights console."
    sql: ${TABLE}.phraseMatcherId ;;
  }

  dimension: revision_id {
    group_label: "Custom Highlights"
    label: "Custom Highlight Revision ID"
    hidden: yes
    type: number
    description: "Indicating the revision of the phrase matcher set up as a custom highlight in the Insights console."
    sql: ${TABLE}.revisionId ;;
  }
  measure: count {
    label: "Custom Highlight Count"
    group_label: "Custom Highlights"
    type: count
  }
}

view: insights_data__sentences__dialogflow_intent_match_data {
  dimension: display_name {
    group_label: "Dialogflow Intents"
    label: "Dialogflow Intent Name"
    type: string
    description: "The human readable name of the matched intent."
    sql: case when ${TABLE}.displayName is null then "No Dialogflow Intent Match" else ${TABLE}.displayName end ;;
  }

  dimension: intent_match_source {
    hidden: yes #field no longer exists in database schema
    group_label: "Dialogflow Intents"
    label: "Dialogflow Intent Source"
    type: string
    description: "The source of the matched intent, either ANALYZE_CONTENT or DETECT_INTENT."
    sql: ${TABLE}.intentMatchSource ;;
  }

  dimension: intent_name {
    hidden:  yes
    group_label: "Dialogflow Intents"
    label: "Dialogflow Intent Name"
    type: string
    description: "The resource name of the matched intent."
    sql: ${TABLE}.intentName ;;
  }

  dimension: max_confidence {
    group_label: "Dialogflow Intents"
    label: "Dialogflow Intent Max Confidence"
    type: number
    description: "The maximum confidence seen for the intent in the current transcript chunk."
    sql: ${TABLE}.maxConfidence ;;
  }
}

view: sentence_turn_number {
  derived_table: {
    sql: SELECT
    insights_data.conversationName  AS conversation_name,
    insights_data__sentences.sentence  AS sentence,
        insights_data__sentences.createTimeNanos AS created_test,
        rank() over(partition by insights_data.conversationName order by insights_data__sentences.createTimeNanos asc) AS turn_number
    FROM @{INSIGHTS_TABLE} AS insights_data
    LEFT JOIN UNNEST(insights_data.sentences) as insights_data__sentences
    GROUP BY
    1,
    2,
    3 ;;
    }

  dimension: conversation_name {
    hidden: yes
    description: "Name of the conversation resource."
  }
  dimension: sentence {
    hidden: yes
    description: "The transcribed sentence."
  }
  dimension: created_test {
    hidden: yes
    type: number
  }
  dimension_group: created {
    hidden: yes
    type: time
    timeframes: [time, hour_of_day, date, day_of_week, week, month_name, year, raw]
    description: "Time in UTC that the conversation message took place, if provided."
    sql: TIMESTAMP_MICROS(CAST(${created_test}/1000 as INT64)) ;;
  }
  dimension: turn_number {
    type: number
    description: "The turn number of the sentence within the conversation."
  }
}

view: human_agent_turns {
  derived_table: {
    sql: WITH sentence_turn_number AS (SELECT
    insights_data.conversationName  AS conversation_name,
    insights_data__sentences.sentence  AS sentence,
    insights_data__sentences.createTimeNanos AS created_test,
    rank() over(partition by insights_data.conversationName order by insights_data__sentences.createTimeNanos asc) AS turn_number
    FROM @{INSIGHTS_TABLE} AS insights_data
    LEFT JOIN UNNEST(insights_data.sentences) as insights_data__sentences
    GROUP BY
    1,
    2,
    3 )
SELECT
    insights_data.conversationName  AS conversation_name,
    min(sentence_turn_number.turn_number) AS first_turn_human_agent
FROM @{INSIGHTS_TABLE} AS insights_data
LEFT JOIN UNNEST(insights_data.sentences) as insights_data__sentences
LEFT JOIN sentence_turn_number ON insights_data.conversationName=sentence_turn_number.conversation_name
    and insights_data__sentences.sentence = sentence_turn_number.sentence
    and (TIMESTAMP_MICROS(CAST(insights_data__sentences.createTimeNanos/1000 as INT64))) = (TIMESTAMP_MICROS(CAST(sentence_turn_number.created_test/1000 as INT64)))
    where insights_data__sentences.participantRole = "HUMAN_AGENT"
GROUP BY
    1 ;;
  }

  dimension: conversation_name {
    hidden: yes
    primary_key:  yes
    description: "Name of the conversation resource."
  }
  dimension: first_turn_human_agent {
    description: "The turn number for the first time a human agent entered a conversation."
  }
  measure: average_first_turn_human_agent {
    type: average
    sql: ${first_turn_human_agent} ;;
    value_format_name: decimal_0
  }
}

view: daily_facts {

  derived_table: {
    explore_source: insights_data {
      column: load_date {}
      column: conversation_type {field:insights_data.type}
      column: conversation_count {}
      column: contained_count {}
      column: entity_count { field: insights_data__entities.count }
      column: topic_count { field: insights_data__topics.count }
      column: contained_percentage {}
    }
  }

  dimension: date_type {
    group_label: "Daily Metrics"
    primary_key: yes
    hidden: yes
    sql: concat(${load_date}," ",${conversation_type}) ;;
  }
  dimension: load_date {
    group_label: "Daily Metrics"
    hidden: yes
    type: date
  }
  dimension: conversation_type {
    group_label: "Daily Metrics"
    hidden: yes
    type: string
  }
  dimension: conversation_count {
    group_label: "Conversation Type"
    hidden: yes
    label: "Insights Data: Conversations Conversation Count"
    type: number
  }
  measure: avg_daily_conversations {
    description: "Average Conversations Per Day"
    group_label: "Daily Metrics"
    type: average
    sql: ${conversation_count} ;;
    value_format_name: decimal_2
    drill_fields: [insights_data.convo_info*]
  }
  dimension: contained_count {
    group_label: "Daily Metrics"
    hidden: yes
    label: "Insights Data: Conversations Contained Count"
    description: "A conversation is considered contained if it was never passed to a human agent."
    type: number
  }
  measure: avg_daily_contained_conversations {
    group_label: "Daily Metrics"
    description: "Average Contained Conversations Per Day"
    type: average
    sql: ${contained_count} ;;
    value_format_name: decimal_2
    drill_fields: [insights_data.convo_info*]
  }
  dimension: entity_count {
    group_label: "Daily Metrics"
    hidden:  yes
    label: "Insights Data: Entities Count"
    type: number
  }
  measure: avg_daily_entities {
    group_label: "Daily Metrics"
    description: "Average Entities Per Day"
    type: average
    value_format_name: decimal_2
    sql: ${entity_count} ;;
  }
  dimension: topic_count {
    group_label: "Daily Metrics"
    hidden: yes
    type: number
  }
  measure: avg_daily_topics {
    group_label: "Daily Metrics"
    description: "Average Topics Per Day"
    type: average
    value_format_name: decimal_2
    sql: ${topic_count} ;;
  }

}
