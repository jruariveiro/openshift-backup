#!bin/sh
set +e

echo "======================================================================"
echo " Parameters:                                                          "
echo " Will restore: $BACKUP_TYPE for project $PROJECT_NAME                  "
echo " Destination: $RESTIC_DESTINATION                                     "
echo " Host $RESTIC_HOST:$RESTIC_S3_PORT                                 "
echo " Repository password: $RESTIC_PASSWORD                                "
echo " Backup tag: $RESTIC_TAG                                              "
echo "======================================================================"

#if [ $BACKUP_TYPE='all-pvc' ]; then
#    export RESTORE_TYPE='metadata'
#    export RESTIC_TAG='metadata'
#else
#    export RESTORE_TYPE=$BACKUP_TYPE
#fi

case $RESTIC_DESTINATION in
    s3)
        echo "Will restore from S3 generic (like Minio) object store - $RESTIC_HOST:$RESTIC_S3_PORT"
#        export RESTIC_REPOSITORY=s3:http://$RESTIC_HOST:$RESTIC_S3_PORT/$PROJECT_NAME/$RESTORE_TYPE/$RESTIC_TAG
        export RESTIC_REPOSITORY=s3:http://$RESTIC_HOST:$RESTIC_S3_PORT/$PROJECT_NAME
    ;;
    aws)
        echo "Will restore from AMAZON S3 storage - $RESTIC_HOST"
#        export RESTIC_REPOSITORY=s3:$RESTIC_HOST/$PROJECT_NAME/$RESTORE_TYPE/$RESTIC_TAG
        export RESTIC_REPOSITORY=s3:$RESTIC_HOST/$PROJECT_NAME
    ;;
esac

case $BACKUP_TYPE in
    metadata)
        echo "Will try to restore project metadata"
        export RESTIC_REPOSITORY=$RESTIC_REPOSITORY/$BACKUP_TYPE/$RESTIC_TAG
        ./metadata-restore.sh
        ;;
    files)
        echo "Will try to restore files for PVC $RESTIC_TAG"
        export RESTIC_REPOSITORY=$RESTIC_REPOSITORY/$BACKUP_TYPE/$RESTIC_TAG
        ./files-restore.sh
        ;;
    databases)
        echo "Will try to restore database with service $DATABASE_SVC"
        export RESTIC_REPOSITORY=$RESTIC_REPOSITORY/$BACKUP_TYPE/$RESTIC_TAG
        ./databases-restore.sh
        ;;
    all-pvc)
        echo "Will try to restore files for all PVC's"
        export RESTIC_REPOSITORY=$RESTIC_REPOSITORY"/metadata/metadata"
        ./restore-all-pvc.sh
        ;;
esac

rc=$?

if [[ $rc == 0 ]]; then
    echo "Restore job finished successful" 
else
    echo "Restore failed with status ${rc}"
    exit
fi




