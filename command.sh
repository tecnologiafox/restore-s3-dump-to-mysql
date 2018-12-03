MOST_RECENT=$(aws s3 ls $FROM_S3_PREFIX | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//' | sort -n | tail -n 1)
FILE_DUMP_COMPRESSED=/tmp/$MOST_RECENT
FILE_DUMP=$FILE_DUMP_COMPRESSED".sql"

echo
echo "Downloading latest dump ($FROM_S3_PREFIX$MOST_RECENT)..."
date
aws s3 cp s3://$FROM_S3_PREFIX$MOST_RECENT $FILE_DUMP_COMPRESSED

echo
echo "Uncompressing dump..."
date
gunzip -c "$FILE_DUMP_COMPRESSED" > "$FILE_DUMP"
rm -rf "$FILE_DUMP_COMPRESSED"

echo
echo "Removing DEFINER= strings from dump to avoid SPECIAL PRIVILEGES error..."
sed -i 's/DEFINER=[^[:space:]]\+//g' "$FILE_DUMP"

echo
echo 'Dropping old database...'
date
mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "DROP DATABASE IF EXISTS \\\`${DB_NAME}\\\`";

echo
echo 'Creating fresh database...'
date
mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" -e "CREATE DATABASE IF NOT EXISTS \\\`${DB_NAME}\\\` COLLATE 'utf8_general_ci'";

echo
echo 'Importing dump into database...'
date
mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < "$FILE_DUMP";

if [ ! -z "$CUSTOM_QUERY" ]; then
    echo
    echo 'Running custom sql script...'
    date
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -e "$CUSTOM_QUERY"
fi

echo
echo 'Removing dump file...'
date
rm -rf "$FILE_DUMP"

echo 'Done!'
