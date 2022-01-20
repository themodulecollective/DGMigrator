SET ANSI_PADDING ON;
/*
  Need to update this to be dynamic based on the selected / configured Attribute Map in the Configuration
*/

DROP INDEX [NCI] ON [dbo].[stagingDistributionGroup];
CREATE UNIQUE NONCLUSTERED INDEX [NCI] ON [dbo].[stagingDistributionGroup]
(
	[SourceOrganization] ASC,
	[ExternalDirectoryObjectID] ASC,
	[PrimarySmtpAddress] ASC,
	[CustomAttribute11] ASC,
	[CustomAttribute12] ASC,
	[CustomAttribute13] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
;

DROP INDEX [NCIWhenChanged] ON [dbo].[stagingDistributionGroup];
CREATE NONCLUSTERED INDEX [NCIWhenChanged] ON [dbo].[stagingDistributionGroup]
(
	[WhenChangedUTC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
;

DROP INDEX [CI] ON [dbo].[historyDistributionGroup];
CREATE UNIQUE CLUSTERED INDEX [CI] ON [dbo].[historyDistributionGroup]
(
	[SourceOrganization] ASC,
	[ExternalDirectoryObjectID] ASC,
	[PrimarySmtpAddress] ASC,
	[CustomAttribute11] ASC,
	[CustomAttribute12] ASC,
	[CustomAttribute13] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
;

DROP INDEX [NCIWhenChanged] ON [dbo].[historyDistributionGroup];
CREATE NONCLUSTERED INDEX [NCIWhenChanged] ON [dbo].[historyDistributionGroup]
(
	[WhenChangedUTC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
;

DROP INDEX [NCI] ON [dbo].[stagingRecipient];
CREATE UNIQUE NONCLUSTERED INDEX [NCI] ON [dbo].[stagingRecipient]
(
	[SourceOrganization] ASC,
	[PrimarySmtpAddress] ASC,
	[ExternalEmailAddress] ASC,
	[CustomAttribute13] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
;

DROP INDEX [NCIRecipientTypeDetails] ON [dbo].[stagingRecipient];
CREATE NONCLUSTERED INDEX [NCIRecipientTypeDetails] ON [dbo].[stagingRecipient]
(
	[RecipientTypeDetails] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
;

DROP INDEX [CI] ON [dbo].[stagingDistributionGroupRole] WITH ( ONLINE = OFF );

CREATE CLUSTERED INDEX [CI] ON [dbo].[stagingDistributionGroupRole]
(
	[ExternalDirectoryObjectID] ASC,
	[TargetGroupExternalDirectoryObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

DROP INDEX [NCI] ON [dbo].[stagingDistributionGroupRole];

CREATE NONCLUSTERED INDEX [NCI] ON [dbo].[stagingDistributionGroupRole]
(
	[PrimarySmtpAddress] ASC,
	[TargetGroupPrimarySmtpAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

DROP INDEX [CI] ON [dbo].[historyDistributionGroupRole] WITH ( ONLINE = OFF );

CREATE CLUSTERED INDEX [CI] ON [dbo].[historyDistributionGroupRole]
(
	[ExternalDirectoryObjectID] ASC,
	[TargetGroupExternalDirectoryObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

DROP INDEX [NCI] ON [dbo].[historyDistributionGroupRole];

CREATE NONCLUSTERED INDEX [NCI] ON [dbo].[historyDistributionGroupRole]
(
	[PrimarySmtpAddress] ASC,
	[TargetGroupPrimarySmtpAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;
