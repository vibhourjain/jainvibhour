# Convert Period to string for categorical X-axis
df['period_label'] = pd.to_datetime(df['Period']).dt.strftime('%d-%b-%Y')

# Sort by Period to preserve time order
df = df.sort_values('Period')

# Line graph
fig_line = px.line(
    df,
    x='period_label',  # categorical for even spacing
    y='Volume',
    color='Application_type',
    markers=True,
    title='Volume Trend by Application Type (Line Chart)'
)

# Bar graph
fig_bar = px.bar(
    df,
    x='period_label',
    y='Volume',
    color='Application_type',
    barmode='group',
    title='Volume Distribution by Application Type (Bar Chart)'
)

# Optional: Style
for fig in [fig_line, fig_bar]:
    fig.update_layout(
        xaxis_title='Period',
        yaxis_title='Volume',
        xaxis_tickangle=-45,
        margin=dict(l=40, r=20, t=60, b=100)
    )