% Auto-generated documentation for function tblEntries 
%  2024-01-26 15:48:14.175276 
\name{tblEntries}
\alias{tblEntries}
\title{Assemble Information About Each Entry in a Table into a Data Frame }
\description{
Assemble information about each entry in a table into a data frame with
one row per entry, and columns for entry content and position in the
table.  This is an internal function, not intended to be called by package
users.
}
\usage{
tblEntries(x, mergeRuns=c(TRUE, TRUE), rowheadInside=FALSE)
}
\arguments{
  \item{x}{A \code{textTable} object, or something that can be coerced to one.
  }
  \item{mergeRuns}{Two-element logical vector, the first element applying to row headers, the
second to column headers.  If TRUE (the default) then header cells that
contain runs of the same value will be merged into a single entry that
spans multiple rows or columns.  Note that runs in the outermost row
header layer are always merged when \code{rowheadInside} is TRUE, even if
\code{mergeRuns[1]} is FALSE.
  }
  \item{rowheadInside}{Logical scalar.  If TRUE, the outermost layer of row headers is moved
inside the table by using its levels to divide the table into groups of
rows, with each group labeled by their level.
  }
}
\value{
An object of S3 class \code{tblEntries}.  This is a data frame with one
row per entry in the table.  It contains descriptors with information
about the nature and position of each entry within the table.  Column
descriptions are in the documentation for the \code{elements} function.
Additional details for certain columns are:
  \item{subpart}{For row and column headers, the subpart will be the name of the
corresponding column in \code{x$rowhead} or row in \code{x$colhead}.
  }
  \item{level_in_layer}{Numbering of entries within a given part and headlayer.  For row and
column headers this is based their hierarchical structure (see
\code{tblBlocks}), and assumes \code{mergeRuns} is TRUE (so multiple
entries within a layer may have the same level number).  For other table
parts it is just an integer from 1 to the number of entries in that layer
of that part.
  }
  \item{type}{Character string identifying the type of value the entry represents (e.g.,
"numeric").  This is taken from the \code{type} attributes of components
of \code{x}, and may be NA for unknown or unspecified type.  The default
for table annotation (\code{title}, \code{subtitle}, \code{foot}) and
\code{rowheadLabels} is "character".
  }
  \item{textspec}{Character string indicating any special features of the text in
\code{text}.  Currently supported values are "plain", "plotmath", and
"markdown".  The default is "plain", but any entry whose text begins with
"MATH_" or "MKDN_" will have \code{textspec} set to "plotmath" or
"markdown", respectively, and the prefix will be removed from \code{text}.
  }
  \item{enabled}{Logical indicating whether the entry is to be displayed.  This function
sets \code{enabled} to FALSE for entries whose \code{text} is NA (with a
warning) or the empty string "", and to TRUE for all other entries.
  }
  \item{hjust}{Numeric horizontal justification specification for entry text (0=left,
0.5=center, 1=right, NA=unspecified).  This is set based on the
\code{justification} attributes of components of \code{x} if present, NA
if not.
  }
Row names for the data frame are set equal to \code{id}.  The data frame
has attributes \code{mergeRuns} and \code{rowheadInside}, based on the
arguments.  It also has attributes \code{rowhier} and \code{colhier},
containing information about the row and column header hierarchies.  They
are lists of data frames, copied from the corresponding components of
\code{x}.  They reflect the logical structure of the headers and are
unaffected by display choices such as \code{mergeRuns} and
\code{rowheadInside}.
}
\details{
Entries include all parts of the table: the body of the table, row and
column headers, titles, subtitles, and foot lines.  This function calls
\code{textTable(x)} to convert table entries to character strings if
necessary.

If the text for an entry is missing (NA) the entry will be disabled, with
a warning.  If the text is an empty string (""), the entry will be
disabled by default; this is so that blocks containing only empty cells
will not have hvrules generated for them.

Row and column numbers used in creating default entry ID's are
\code{partrow} and \code{partcol}, and thus with respect to the dimensions
of the table part the entry belongs to, not the augmented row-column grid.
If an entry spans more than one row or column, the minimum row/column
number of the spanned cells is used.

The \code{rowhier} and \code{colhier} attributes are included primarily to
assist creation of table blocks by function \code{tblBlocks}.

The inclusion of the \code{hjust} column is not tidy, since it is really a
graphical display property.  However it is needed to carry forward
justification information that \code{x} may have inherited from a
\code{tabular} object.

The \code{tblEntries} method for \code{textTable} is the inverse of this
function: it will re-create a \code{textTable} from a \code{tblEntries}
object.
}
\seealso{
\code{\link{textTable}}, \code{\link{tblParts}};
\code{\link{as.tblEntries}}, \code{\link{elements}}.
}
\keyword{internal}
